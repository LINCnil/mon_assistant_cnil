
import UIKit

extension NSNotification {
    var keyboardAnimationDuration: TimeInterval {
        guard
            let userInfo = userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return 0
        }
        return duration
    }

    var keyboardAnimationCurve: UIView.AnimationCurve {
        guard
            let userInfo = userInfo,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve else {
            return UIView.AnimationCurve.easeInOut
        }
        return curve
    }

    var keyboardFrameEnd: CGRect {
        guard
            let userInfo = userInfo,
            let rect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return .zero
        }
        return rect
    }
}
