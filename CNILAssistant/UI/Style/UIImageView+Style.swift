import UIKit

extension ViewStyle where T == UIImageView {

    static func tintedImage(_ image: UIImage, tintColor: UIColor) -> ViewStyle<UIImageView> {
        return ViewStyle<UIImageView> {
            $0.tintColor = tintColor
            $0.image = image.withRenderingMode(.alwaysTemplate)
        }
    }
}
