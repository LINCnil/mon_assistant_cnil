
import UIKit

@IBDesignable
final class SeparatorView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 1, height: 1 / UIScreen.main.scale)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        invalidateIntrinsicContentSize()
    }
}
