

import UIKit
import SFSafeSymbols

extension ViewStyle where T == UIBarButtonItem {
    static func toggleSpeaking(isSpeaking: Bool) -> ViewStyle<UIBarButtonItem> {
        let image: UIImage = UIImage(systemSymbol: isSpeaking ? .pauseCircle : .playCircle)
        return ViewStyle<UIBarButtonItem> {
            $0.image = image
        }
    }

    static func bookmark(isFilled: Bool) -> ViewStyle<UIBarButtonItem> {
        let image: UIImage = UIImage(systemSymbol: isFilled ? .bookmarkFill : .bookmark)
        return ViewStyle<UIBarButtonItem> {
            $0.image = image
        }
    }

    static let settings = ViewStyle<UIBarButtonItem> {
        $0.image = .app_gearshapeIcon
    }

    static let trash = ViewStyle<UIBarButtonItem> {
        $0.image = UIImage(systemSymbol: .trash)
    }

    static let share = ViewStyle<UIBarButtonItem> {
        $0.image = UIImage(systemSymbol: .squareAndArrowUp)
    }
}
