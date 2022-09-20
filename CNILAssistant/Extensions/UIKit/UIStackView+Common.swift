

import Foundation
import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        for subView in arrangedSubviews {
            removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
    }
}
