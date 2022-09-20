
import Foundation
import RxSwift
import RxCocoa
import AVFoundation
import NaturalLanguage
import RxDataSources
import Action
import Zip
import HybridNlpEngine

struct AudioSessionError: Error, LocalizedError {
    let title = "Audio Session Error"
    let message: String

    var errorDescription: String? {
        message
    }
}

protocol ConversationViewModelDelegate: class {
    func didSelectAnswer(_ answer: AnswerContent)
    func didSelectSettings()
    func didSelectBookmarks()
    func didRequestOpenUrl(_ url: URL)
}

class ConversationViewModel {
    let title = L10n.Localizable.conversationTitle
    let messages = BehaviorRelay<[ConversationTableSectionModel<ConversationEntryViewModel>]>(
        value: [ConversationTableSectionModel(items: [])])

    let inputViewPlaceholder = L10n.Localizable.conversationInputViewPlaceholder
    let updatingModelTitle = L10n.Localizable.conversationUpdatingModelTitle
    let updatingModelMessage = L10n.Localizable.conversationUpdatingModelMessage

    let isModelLoaded = BehaviorRelay<Bool>(value: false)
    let isModelUpdating = BehaviorRelay<Bool>(value: false)

    let isRecording = BehaviorRelay<Bool>(value: false)
    let isRecordingPermissionsGranted = BehaviorRelay<Bool>(value: false)

    let isProcessing = BehaviorRelay<Bool>(value: false)

    let alert = PublishSubject<RxAlert>()

    private let newsUrl = URL(string: "https://www.cnil.fr/fr/actualites")!

    private(set) var selectSettings: CocoaAction!
    private(set) var selectBookmarks: CocoaAction!

    weak var delegate: ConversationViewModelDelegate?

    private let modelProvider: ModelProvider

    private var processingService: ProcessingService?
    private var answerRepository: AnswerRepository?

    private var audioRecorder: AudioRecorder?
    private var resourcePlayer: AVAudioPlayer?
    private var speechSynthesizer: SpeechSynthesizer

    private let speekingEntryModelId = BehaviorRelay<UUID?>(value: nil)

    private let disposeBag = DisposeBag()

    init() {
        self.modelProvider = DependencyProvider.shared.modelProvider()
        self.speechSynthesizer = AVSpeechSynthesizerImplementation()
        self.speechSynthesizer.onSpeakCompleted = { [weak self] in
            self?.speekingEntryModelId.accept(nil)
        }

        self.selectSettings = CocoaAction { [unowned self] in
            return Observable.create { [unowned self] observer in
                self.delegate?.didSelectSettings()
                observer.onCompleted()
                return Disposables.create {}
            }
        }

        self.selectBookmarks = CocoaAction { [unowned self] in
            return Observable.create { [unowned self] observer in
                self.delegate?.didSelectBookmarks()
                observer.onCompleted()
                return Disposables.create {}
            }
        }

        initializeModel()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func stopCaptureVoice() {
        audioRecorder?.stop()
    }

    func notifySettingsChanged() {
        stopPlaying()
    }

    func startCaptureVoice() {
        do {
            try activateAudioSession()
        } catch {
            showAlert(title: "Audio Session Error", message: error.localizedDescription)
            return
        }

        if audioRecorder == nil {
            do {
                audioRecorder = try createAudioRecorder()
            } catch {
                showAlert(title: "Audio Session Error", message: "Failed to create Audio Recorder")
                return
            }
        }

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        isRecording.accept(true)
        isProcessing.accept(false)

        stopPlaying()

        let duration = 10.0
        self.audioRecorder!.record(duration: duration, levelMonitor: { _ in }, completion: { [weak self] result in
            guard let self = self else { return }

            self.isRecording.accept(false)

            switch result {
            case .success(let wavFileURL):
                self.resourcePlayer = AVAudioPlayer.playerForSoundResource("listening_end", type: .wav)
                self.resourcePlayer?.play()

                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()

                self.performProcessing(source: .audioFile(url: wavFileURL))
            case .failure(let error):
                switch error {
                case is NoVoiceError:
                    self.resourcePlayer = AVAudioPlayer.playerForSoundResource("mic_off", type: .wav, rate: 1.7, numberOfLoops: 1)
                    self.resourcePlayer?.play()
                default:
                    break
                }
            }
        })
    }

    func initAudioSession() {
        registerForAudioSessionNotifications()
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(
                AVAudioSession.Category.playAndRecord,
                options: [.allowBluetoothA2DP, .allowBluetooth, .defaultToSpeaker])

            audioSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    self.isRecordingPermissionsGranted.accept(allowed)
                    if !allowed {
                        self.showAlert(title: nil, message: L10n.Localizable.conversationDeniedRecordAudioPermission)
                    }
                }
            }
        } catch {
            showAlert(title: "Audio Session Error", message: "Unsupported audio session category")
        }
    }

    func releaseAudioSession() {
        releaseAudioSessionObjects()
    }

    private func registerForAudioSessionNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMediaServicesNotification),
            name: AVAudioSession.mediaServicesWereLostNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMediaServicesNotification),
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChangeNotification),
            name: AVAudioSession.routeChangeNotification,
            object: nil)
    }

    @objc private func handleMediaServicesNotification(_ notification: Notification) {
        releaseAudioSessionObjects()
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            releaseAudioSessionObjects()
        }
    }

    @objc private func handleRouteChangeNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        if reason == AVAudioSession.RouteChangeReason.override ||
            reason == AVAudioSession.RouteChangeReason.categoryChange {
            if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint {
                DispatchQueue.main.async {
                    self.releaseAudioSessionObjects()
                }
            }
        }
    }

    private func activateAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            throw AudioSessionError(message: "Audio session is busy, please end another usage like phone call, facetime, etc")
        }
    }

    private func releaseAudioSessionObjects() {
        audioRecorder?.cancel()
        audioRecorder = nil
        isRecording.accept(false)

        stopPlaying()
    }

    private func createAudioRecorder() throws -> AudioRecorder {
        let directoryURL = FileManager.default.getDocumentsDirectory()
        return try AudioRecorder(configuration: AudioRecorder.Configuration(resultFileDirectoryURL: directoryURL))
    }

    private func showAlert(title: String?, message: String?) {
        alert.onNext(
            RxAlert(title: title, message: message, actions: [
                RxAlertAction(title: L10n.Localizable.alertActionOk, action: nil)
            ]))
    }

    private func showUpdateAvailableAlert(availableModel: RemoteModel) {
        alert.onNext(
            RxAlert(title: L10n.Localizable.conversationUpdateModelAvailableTitle,
                    message: L10n.Localizable.conversationUpdateModelAvailableMessage,
                    actions: [
                        RxAlertAction(title: L10n.Localizable.conversationUpdateModelAvailableActionUpdate, action: { [weak self] in
                            self?.updateModel(availableModel: availableModel)
                        }),
                        RxAlertAction(title: L10n.Localizable.conversationUpdateModelAvailableActionRemindLater, action: nil)
                    ]))
    }

    private func updateModel(availableModel: RemoteModel) {
        isModelUpdating.accept(true)
        isModelLoaded.accept(false)
        modelProvider.downloadAndInstall(model: availableModel) { [weak self] res in
            guard let self = self else { return }

            self.isModelUpdating.accept(false)

            switch res {
            case .success(let modelDescription):
                do {
                    try self.prepareProcessingService(modelDescription)
                    self.isModelLoaded.accept(true)
                } catch {
                    self.showAlert(title: "Can not initialize model", message: error.localizedDescription)
                    self.isModelLoaded.accept(false)
                }
            case .failure:
                self.isModelLoaded.accept(true)
                self.showAlert(
                    title: L10n.Localizable.conversationUpdateModelFailedTitle,
                    message: L10n.Localizable.conversationUpdateModelFailedMessage)
            }
        }
    }

    func stopPlaying() {
        resourcePlayer?.stop()
        resourcePlayer = nil

        speechSynthesizer.stopSpeaking()
        speekingEntryModelId.accept(nil)
    }

    func selectAnswer(_ answer: AnswerContent) {
        delegate?.didSelectAnswer(answer)
    }

    func performProcessing(text: String) {
        audioRecorder?.cancel()
        stopPlaying()
        performProcessing(source: .text(text: text))
    }

    private func performProcessing(source: DataSource) {
        guard let processingService = processingService else {
            return
        }

        self.isProcessing.accept(true)

        let start = CFAbsoluteTimeGetCurrent()
        processingService.processData(dataSource: source) { [weak self] result in
            guard let self = self else { return }

            let diff = CFAbsoluteTimeGetCurrent() - start
            print("Processing took \(diff) seconds")

            self.isProcessing.accept(false)

            switch result {
            case .success(let answer):
                self.handleAnswer(answer)
            case .failure(let error):
                switch error {
                case ClassifierError.noWordsInText(let text), ClassifierError.noResults(let text):
                    self.set(ItemViewModelHolder(viewModel: NoResultEntryViewModel(questionText: text)))
                default:
                    self.showAlert(title: "Processing Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func handleAnswer(_ answer: Answer) {
        set(answer.proposals.map { createAnswerItem(answer: $0) })
    }

    private func createAnswerItem(answer: AnswerContent) -> ItemViewModelHolder<ConversationEntryViewModel> {
        let viewModelHolder: ItemViewModelHolder<ConversationEntryViewModel> = ItemViewModelHolder { _ in
            AnswerEntryViewModel(answer: answer)
        }
        return viewModelHolder
    }

    private func createWelcomeItem(answers: [AnswerContent]) -> ItemViewModelHolder<ConversationEntryViewModel> {
        let viewModelHolder: ItemViewModelHolder<ConversationEntryViewModel> = ItemViewModelHolder { [unowned self] _ in
            WelcomeEntryViewModel(
                suggestions: answers,
                onSuggestionSelected: { selectedSuggestion in
                    delegate?.didSelectAnswer(selectedSuggestion)
                },
                onBookmarksSelected: { [unowned self] in
                    delegate?.didSelectBookmarks()
                },
                onNewsSelected: {
                    delegate?.didRequestOpenUrl(self.newsUrl)
                })
        }
        return viewModelHolder
    }

    private func onSpeakingToggled(entryModelId: UUID, htmlAnswer: NSAttributedString) {
        var newSpeakingEntryModelId: UUID?

        if let speekingUuid = speekingEntryModelId.value {
            speechSynthesizer.stopSpeaking()
            if speekingUuid != entryModelId {
                speechSynthesizer.speak(htmlAnswer)
                newSpeakingEntryModelId = entryModelId
            }
        } else {
            speechSynthesizer.speak(htmlAnswer)
            newSpeakingEntryModelId = entryModelId
        }

        speekingEntryModelId.accept(newSpeakingEntryModelId)
    }

    private func createSpeakingObservable(_ entryModelId: UUID) -> Observable<Bool> {
        self.speekingEntryModelId.map { uuid in
            uuid == entryModelId
        }
    }

    private func set(_ items: [ItemViewModelHolder<ConversationEntryViewModel>]) {
        var section = self.messages.value[0]
        section.set(items)
        self.messages.accept([section])
    }

    private func set(_ element: ItemViewModelHolder<ConversationEntryViewModel>) {
        set([element])
    }

    private func append(_ items: [ItemViewModelHolder<ConversationEntryViewModel>]) {
        var section = self.messages.value[0]
        section.append(items)
        self.messages.accept([section])
    }

    private func append(_ element: ItemViewModelHolder<ConversationEntryViewModel>) {
        var section = self.messages.value[0]
        section.append(element)
        self.messages.accept([section])
    }

    private func replace(_ element: ItemViewModelHolder<ConversationEntryViewModel>,
                         with newElement: ItemViewModelHolder<ConversationEntryViewModel>) {
        var section = self.messages.value[0]
        section.replace(element: element, with: newElement)
        self.messages.accept([section])
    }

    private func remove(_ element: ItemViewModelHolder<ConversationEntryViewModel>) {
        var section = self.messages.value[0]
        section.remove(element: element)
        self.messages.accept([section])
    }

    private func initializeModel() {
        if let modelDescription = modelProvider.installedModel,
           modelDescription.version.archVersion == AppConfiguration.supportedModelArchVersion {
            do {
                try prepareProcessingService(modelDescription)
                isModelLoaded.accept(true)
                checkForUpdate()
            } catch {
                self.showAlert(title: "Can not initialize model", message: error.localizedDescription)
                self.isModelLoaded.accept(false)
            }
        } else {
            modelProvider.installModel(from: modelProvider.embeddedModelUrl) { res in
                switch res {
                case .success(let modelDescription):
                    do {
                        try self.prepareProcessingService(modelDescription)
                        self.isModelLoaded.accept(true)
                        self.checkForUpdate()
                    } catch {
                        self.isModelLoaded.accept(false)
                        self.showAlert(title: "Can not initialize model", message: error.localizedDescription)
                    }
                case .failure(let error):
                    self.isModelLoaded.accept(false)
                    self.showAlert(title: "Can not initialize model", message: error.localizedDescription)
                }
            }
        }
    }

    private func prepareProcessingService(_ modelDescription: ModelDescription) throws {
        DependencyProvider.shared.resetModelRelatedObjects()
        processingService = nil
        answerRepository = nil

        DependencyProvider.shared.loadModelRelatedObjects(modelDescription: modelDescription)
        answerRepository = DependencyProvider.shared.answerRepository()
        processingService = try DependencyProvider.shared.processingService()

        answerRepository?.getAnswers(for: [533], completion: { [unowned self] res in
            switch res {
            case .success(let answers):
                self.set(createWelcomeItem(answers: answers))
            case .failure(let error):
                print("Can not load suggestions, error: \(error.localizedDescription)")
            }
        })
    }

    private func checkForUpdate() {
        modelProvider.checkForUpdate { [weak self] res in
            guard let self = self else { return }
            switch res {
            case .success(let latestModel):
                let installedVersion = self.modelProvider.installedModel?.version.fullName ?? "N/A"
                print("Latest version of model on server: \(latestModel.version.fullName), installed: \(installedVersion)")
                if latestModel.version.archVersion == AppConfiguration.supportedModelArchVersion
                    && latestModel.version.fullName != installedVersion {
                    self.showUpdateAvailableAlert(availableModel: latestModel)
                }
            case .failure(let error):
                print("Can not check new version, error: \(error.localizedDescription)")
            }
        }
    }
}
