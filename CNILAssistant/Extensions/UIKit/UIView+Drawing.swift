
import Foundation
import UIKit

extension UIView {
    func drawCircle(of size: CGFloat, in rect: CGRect, lineWidth: CGFloat, strokeColor: UIColor, fillColor: UIColor) {
        let path = circleBezierPath(of: size, in: rect, lineWidth: lineWidth)
        strokeColor.setStroke()
        fillColor.setFill()
        path.lineWidth = lineWidth
        path.stroke()
        path.fill()
    }

    func circleBezierPath(of size: CGFloat, in rect: CGRect, lineWidth: CGFloat) -> UIBezierPath {
        let targetRect = CGRect(
            x: rect.midX - size / 2 + lineWidth / 2,
            y: rect.midY - size / 2 + lineWidth / 2,
            width: size - lineWidth,
            height: size - lineWidth)
        return UIBezierPath(ovalIn: targetRect)
    }
}
