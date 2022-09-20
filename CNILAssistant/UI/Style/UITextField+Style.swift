import UIKit

extension ViewStyle where T == UITextField {
    static let input = ViewStyle<UITextView> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 16))
        $0.textColor = .app_textInputPrimary
    }
}
