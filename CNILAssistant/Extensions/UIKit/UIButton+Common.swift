

import Foundation
import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        var resultImage: UIImage! = nil
        if #available(iOSApplicationExtension 13.0, *) {
            resultImage = UIImage(color: color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .unspecified)))
            if let lightImage = UIImage(color: color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))) {
                resultImage?.imageAsset?.register(lightImage, with: UITraitCollection(userInterfaceStyle: .light))
            }
            if let darkImage = UIImage(color: color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))) {
                resultImage?.imageAsset?.register(darkImage, with: UITraitCollection(userInterfaceStyle: .dark))
            }
        } else {
            resultImage = UIImage(color: color)
        }

        self.setBackgroundImage(resultImage, for: state)
    }
}
