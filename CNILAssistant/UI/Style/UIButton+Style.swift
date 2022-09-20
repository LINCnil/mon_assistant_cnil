import UIKit
import SFSafeSymbols

extension ViewStyle where T == UIButton {

    static func image(_ image: UIImage) -> ViewStyle<UIButton> {
        return ViewStyle<UIButton>.base
            .compose { $0.setImage(image, for: .normal) }
    }

    static let microphone = ViewStyle<UIButton>.base.compose {
        $0.tintColor = .app_tint
        $0.setImage(UIImage.app_microphoneIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.setBackgroundImage(.app_microphoneButtonBackground, for: .normal)
    }

    static let processing = ViewStyle<UIButton>.base.compose {
        $0.tintColor = .app_tint
        $0.setImage(UIImage(), for: .normal)
        $0.setBackgroundImage(.app_processingButtonBackground, for: .normal)
    }

    static let listening = ViewStyle<UIButton>.base.compose {
        $0.tintColor = .app_tint
        $0.setImage(UIImage.app_listeningIcon, for: .normal)
        $0.setBackgroundImage(.app_listeningButtonBackground, for: .normal)
    }

    static let send = ViewStyle<UIButton>.base.compose {
        $0.tintColor = .app_tint
        $0.setImage(UIImage.app_sendIcon.withRenderingMode(.alwaysTemplate), for: .normal)
    }

    static func toggleKeyboard(isKeyboardVisible: Bool) -> ViewStyle<UIButton> {
        let image: UIImage = UIImage(systemSymbol: isKeyboardVisible ? .keyboardChevronCompactDown : .keyboard)
        return ViewStyle<UIButton>.base
            .compose {
                $0.tintColor = .app_buttonTint
                $0.setImage(image, for: .normal)
                $0.setBackgroundColor(.app_background, for: .normal)
            }
    }

    static func toggleSpeaking(isSpeaking: Bool) -> ViewStyle<UIButton> {
        let image: UIImage = UIImage(systemSymbol: isSpeaking ? .pauseCircle : .playCircle)
        return ViewStyle<UIButton>.base
            .compose {
                $0.setImage(image, for: .normal)
            }
    }

    static let bookmarks = ViewStyle<UIButton>.base.compose {
        $0.tintColor = .app_buttonTint
        $0.setImage(UIImage(systemSymbol: .bookmark).withRenderingMode(.alwaysTemplate), for: .normal)
        $0.setBackgroundColor(.app_background, for: .normal)
    }

    static let conversationOptionButton = ViewStyle<UIButton>.base.compose {
        $0.setTitleColor(.app_tint, for: .normal)
        $0.setBackgroundColor(.app_buttonOptionBackground, for: .selected)
        $0.setBackgroundColor(.app_buttonOptionBackground, for: .highlighted)

        $0.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 14))
        $0.titleLabel?.numberOfLines = 0
        $0.contentHorizontalAlignment = .left
        $0.contentEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 8)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.app_buttonOptionBorder.cgColor
    }

    static let fillButton = ViewStyle<UIButton>.base.compose {
        $0.setTitleColor(.app_buttonFillButtonTint, for: .normal)
        $0.setBackgroundColor(.app_buttonBackground, for: .normal)
        $0.setBackgroundColor(.app_buttonOptionBackground, for: .selected)
        $0.setBackgroundColor(.app_buttonOptionBackground, for: .highlighted)

        $0.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 16, weight: .medium))

        $0.contentEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 8)
        $0.layer.cornerRadius = 4
    }

    static let tintedButton = ViewStyle<UIButton>.base.compose {
        $0.setTitleColor(.app_tint, for: .normal)
        $0.setTitleColor(UIColor.app_tint.withAlphaComponent(0.4), for: .selected)
        $0.setTitleColor(UIColor.app_tint.withAlphaComponent(0.4), for: .highlighted)

        $0.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 16, weight: .medium))

        $0.contentEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 8)
        $0.layer.cornerRadius = 4
    }

    static let welcomeOptionButton = ViewStyle<UIButton> {
        let image = UIImage.app_radioButtonIcon.withTintColor(.app_labelSecondary)
        let filledImage = UIImage.app_radioButtonFilledIcon.withTintColor(.app_tint)
        $0.setImage(image, for: .normal)
        $0.setImage(filledImage, for: .selected)
        $0.setImage(filledImage, for: .highlighted)

        $0.setTitleColor(.app_labelSecondary, for: .normal)
        $0.setTitleColor(.app_tint, for: .selected)
        $0.setTitleColor(.app_tint, for: .highlighted)

        $0.contentHorizontalAlignment = .center
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.app_buttonOptionBorder.cgColor
    }

    // MARK: - Private

    private static let base = ViewStyle<UIButton> {
        $0.adjustsImageWhenHighlighted = true
    }
}
