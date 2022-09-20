import UIKit

extension ViewStyle where T == UILabel {
    static let header = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 16, weight: .medium))
        $0.textColor = .app_labelPrimary
    }

    static let title = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 16))
        $0.textColor = .app_labelPrimary
    }

    static let text = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 14))
        $0.textColor = .app_labelPrimary
    }

    static let details = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 14))
        $0.textColor = .app_labelSecondary
    }

    static let accent = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 14))
        $0.textColor = .app_labelTertiary
    }

    static let caption = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_italicFont(ofSize: 12))
        $0.textColor = .app_labelPrimary
    }

    static let articlePageFooter = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_italicFont(ofSize: 12))
        $0.textColor = .app_labelTertiary
    }

    static let conversationQuestionMessage = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 16, weight: .medium))
        $0.textColor = .app_labelPrimary
    }

    static let conversationAnswerMessage = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 14))
        $0.textColor = .app_labelPrimary
    }

    static let tableEmptyPlaceholderTitle = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 16, weight: .medium))
        $0.textColor = .app_labelTertiary
    }

    static let tableEmptyPlaceholderDetails = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 14))
        $0.textColor = .app_labelTertiary
    }

    static let welcomeHeader = ViewStyle<UILabel> {
        $0.font = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 24, weight: .medium))
        $0.textColor = .app_labelPrimary
    }
}
