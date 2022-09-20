
import Foundation

class ApplicationSettings: NameDescribable {
    static let shared = ApplicationSettings()

    private static let isFirstLaunchSetupCompletedKey = "\(typeName).isFirstLaunchSetupCompleted"
    private static let speechVoiceGenderKey = "\(typeName).voiceGender"
    private static let speechAutostartEnabledKey = "\(typeName).speechAutostartEnabled"
    private static let speakFullArticleEnabledKey = "\(typeName).speakFullArticleEnabled"
    private static let isAudioLogsEnabledKey = "\(typeName).audioLogs"

    var speechVoiceGender: SpeechSynthesizerVoiceGender {
        get {
            let defaultValue = SpeechSynthesizerVoiceGender.female
            let savedIntValue = UserDefaults.standard.integer(
                forKey: Self.speechVoiceGenderKey,
                or: defaultValue.rawValue)
            return SpeechSynthesizerVoiceGender(rawValue: savedIntValue) ?? defaultValue
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Self.speechVoiceGenderKey)
        }
    }

    var isSpeechAutostartEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Self.speechAutostartEnabledKey, or: true)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Self.speechAutostartEnabledKey)
        }
    }

    var isSpeakFullArticleEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Self.speakFullArticleEnabledKey, or: true)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Self.speakFullArticleEnabledKey)
        }
    }

    var isAudioLogsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Self.isAudioLogsEnabledKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Self.isAudioLogsEnabledKey)
        }
    }

    var isFirstLaunchSetupCompleted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Self.isFirstLaunchSetupCompletedKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Self.isFirstLaunchSetupCompletedKey)
        }
    }
}
