import Foundation
import RxSwift
import RxCocoa
import Action

protocol SettingsViewModelDelegate: class {
    func didSelectLogs()
    func didRequestSelectionOf(setting: String, options: [String], selected: Int?, completion: @escaping (Int?) -> Void)

    func didChangeSettings()
}

class SettingsViewModel {
    let title = BehaviorRelay(value: L10n.Localizable.settingsTitle)
    let settings: BehaviorRelay<[SettingsTableSectionModel]> = BehaviorRelay(value: [])

    weak var delegate: SettingsViewModelDelegate?

    private let modelProvider: ModelProvider

    init() {
        modelProvider = DependencyProvider.shared.modelProvider()
        reloadSettings()
    }

    func reloadSettings() {
        let aboutSection = SettingsTableSectionModel(
            title: L10n.Localizable.settingsAboutSectionTitle,
            items: [
                InfoSettingItem(
                    title: L10n.Localizable.settingsAboutAppVersion,
                    details: UIApplication.formattedFullVersion),
                InfoSettingItem(
                    title: L10n.Localizable.settingsAboutModelVersion,
                    details: modelProvider.installedModel?.version.fullName ?? "N/A")
            ])

        let voiceSettingsSection = SettingsTableSectionModel(
            title: L10n.Localizable.settingsAboutSectionTitle,
            items: [
                createVoiceSettingItem(),
                createSpeechAutostartSettingItem(),
                createSpeakFullArticleSettingItem()
            ])

        #if PROD
        let sections = [
            voiceSettingsSection,
            aboutSection
        ]
        #else

        let logsSection = SettingsTableSectionModel(
            title: "",
            items: [
                TitleSettingItem(
                    title: L10n.Localizable.settingsLogsTitle,
                    onSelected: { [weak self] in
                        self?.delegate?.didSelectLogs()
                    }),
                createAudioLogsSettingItem()
            ])

        let sections = [
            voiceSettingsSection,
            logsSection,
            aboutSection
        ]
        #endif
        settings.accept(sections)
    }

    private func createVoiceSettingItem() -> TitleDetailsSettingItem {
        let selected = ApplicationSettings.shared.speechVoiceGender == .male ? 0 : 1
        let options = [L10n.Localizable.settingsVoiceOptionMale, L10n.Localizable.settingsVoiceOptionFemale]
        let voiceTitle = L10n.Localizable.settingsVoiceTitle
        return TitleDetailsSettingItem(title: voiceTitle, details: options[selected], onSelected: { [weak self] in
            self?.delegate?.didRequestSelectionOf(setting: voiceTitle, options: options, selected: selected) { [weak self] selectedOption in
                if let selectedOption = selectedOption {
                    ApplicationSettings.shared.speechVoiceGender = selectedOption == 0 ? .male : .female
                }
                self?.reloadSettings()
                self?.delegate?.didChangeSettings()
            }
        })
    }

    private func createSpeechAutostartSettingItem() -> BoolSettingItem {
        let enabled = ApplicationSettings.shared.isSpeechAutostartEnabled
        return BoolSettingItem(title: L10n.Localizable.settingsVoiceSpeechAutostart, isOn: enabled) { [weak self] selectedValue in
            ApplicationSettings.shared.isSpeechAutostartEnabled = selectedValue
            self?.delegate?.didChangeSettings()
        }
    }

    private func createSpeakFullArticleSettingItem() -> BoolSettingItem {
        let enabled = ApplicationSettings.shared.isSpeakFullArticleEnabled
        return BoolSettingItem(title: L10n.Localizable.settingsVoiceSpeakFullArticle, isOn: enabled) { [weak self] selectedValue in
            ApplicationSettings.shared.isSpeakFullArticleEnabled = selectedValue
            self?.delegate?.didChangeSettings()
        }
    }

    #if !PROD
    private func createAudioLogsSettingItem() -> BoolSettingItem {
        let enabled = ApplicationSettings.shared.isAudioLogsEnabled
        return BoolSettingItem(title: L10n.Localizable.settingsAudioLogsTitle, isOn: enabled) { [weak self] selectedValue in
            ApplicationSettings.shared.isAudioLogsEnabled = selectedValue
            self?.delegate?.didChangeSettings()
        }
    }
    #endif
}
