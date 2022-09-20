import UIKit

extension ViewStyle where T == UIView {
    static let conversationContainerView = ViewStyle<UIView> {
        $0.backgroundColor = .app_background
        $0.layer.cornerRadius = 8.0
        $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 1.0
        $0.layer.masksToBounds = false
        $0.clipsToBounds = false
    }

    static let conversationRoundingView = ViewStyle<UIView> {
        $0.backgroundColor = .app_background
        $0.layer.cornerRadius = 8.0
        $0.layer.masksToBounds = true
        $0.clipsToBounds = true
    }
}
