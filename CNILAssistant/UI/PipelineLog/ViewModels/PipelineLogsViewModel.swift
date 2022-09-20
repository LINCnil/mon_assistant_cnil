import Foundation
import RxSwift
import RxCocoa
import Action

class PipelineLogsViewModel {
    let messages: BehaviorRelay<[PipelineLogEntryViewModel]> = BehaviorRelay(value: [])
    let title = BehaviorRelay(value: L10n.Localizable.settingsLogsTitle)

    private let logRepository: PipelineLogRepository

    private(set) lazy var clean: CocoaAction = CocoaAction(workFactory: { [unowned self] in
        self.logRepository.removeAll()
        return self.reloadAsync()
    })

    private(set) lazy var share: CocoaAction = CocoaAction(workFactory: { [unowned self] in
        return self.shareAsync()
    })

    private(set) lazy var reload: CocoaAction = CocoaAction(workFactory: { [unowned self] in
        return self.reloadAsync()
    })

    init() {
        self.logRepository = InMemoryPipelineLogRepositoryImplemention.current
    }

    private func reloadAsync() -> Observable<Void> {
        return Observable.create { [unowned self] observer in
            self.logRepository.getAll { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let logs):
                    self.messages.set(elements: logs.map { PipelineLogEntryViewModel(log: $0)}.reversed())
                    observer.on(.completed)
                case .failure(let error):
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }
    }

    private func shareAsync() -> Observable<Void> {
        return Observable.create { [unowned self] observer in
            self.logRepository.getAll { result in
                switch result {
                case .success(let logs):
                    let lines = logs.map { "\($0.tag) [\(DateFormatter.logDateFormatter.string(from: $0.date))]: \($0.entry)" }
                    let joined = lines.joined(separator: "\n")
                    do {
                        let logsDirectory = FileManager.default.getDocumentsDirectory()
                            .appendingPathComponent("Logs")
                        if !FileManager.default.fileExists(at: logsDirectory) {
                            try? FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true, attributes: nil)
                        }
                        let fileURL = logsDirectory.appendingPathComponent("log_\(DateFormatter.fileNameFormatter.string(from: Date())).txt")
                        try joined.write(to: fileURL, atomically: true, encoding: .utf8)
                        observer.on(.completed)
                    } catch {
                        observer.onError(error)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }
    }
}
