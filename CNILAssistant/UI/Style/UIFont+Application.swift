import UIKit

extension UIFont {
    static func app_font(ofSize size: CGFloat) -> UIFont {
        .systemFont(ofSize: size, weight: .regular)
    }

    static func app_boldFont(ofSize size: CGFloat) -> UIFont {
        systemFont(ofSize: size, weight: .bold)
    }

    static func app_font(ofSize size: CGFloat, weight: Weight) -> UIFont {
        systemFont(ofSize: size, weight: weight)
    }

    static func app_italicFont(ofSize size: CGFloat) -> UIFont {
        italicSystemFont(ofSize: size)
    }

    static func app_italicFont(ofSize size: CGFloat, weight: Weight) -> UIFont {
        app_font(ofSize: size, weight: weight).withTraits(traits: .traitItalic)
    }

    private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) // size 0 means keep the size as it is
    }
}
