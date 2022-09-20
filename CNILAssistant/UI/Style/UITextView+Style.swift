import UIKit

extension ViewStyle where T == UITextView {
    static let conversationQuestionMessage = ViewStyle<UITextView>
        .commonHTML
        .compose {
            $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 16, weight: .medium))
            $0.textColor = .app_labelPrimary
        }

    static let conversationAnswerMessage = ViewStyle<UITextView>
        .commonHTML
        .compose {
            $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 14))
            $0.textColor = .app_labelPrimary
        }

    // MARK: - Private

    private static let commonHTML = ViewStyle<UITextView> {
        $0.isScrollEnabled = false
        $0.textContainerInset = .zero
        $0.textContainer.lineFragmentPadding = 0
        $0.isEditable = false
        $0.isSelectable = true
    }
}

extension ViewStyle where T == UITextViewWithPlaceholder {
    static let input = ViewStyle<UITextViewWithPlaceholder> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 14))
        $0.textColor = .app_textInputPrimary
        $0.placeholderColor = .app_textInputPlaceholder
        $0.textContainer.lineFragmentPadding = 0
        $0.textContainerInset = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
    }
}
