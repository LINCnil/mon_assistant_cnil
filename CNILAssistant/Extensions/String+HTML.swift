

import Foundation
import UIKit

extension String {
    func styledHtmlString(fontSize: CGFloat, color: UIColor) -> String {
        let htmlTemplate = """
            <!doctype html>
            <html>
              <head>
                <style>
                  body {
                    font-family: -apple-system;
                    font-size: \(fontSize)px;
                    color: #\(color.hexString);
                  }
                </style>
              </head>
              <body>
                \(self)
              </body>
            </html>
            """
        return htmlTemplate
    }

    func htmlAttributed() -> NSAttributedString {
        guard let data = self.data(using: .utf8) else {
            return NSAttributedString(string: self)
        }
        do {
            let result = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            return result.trim() // apple may add a trailing \n
        } catch {
            return NSAttributedString(string: self)
        }
    }

    func firstSentence() -> String {
        var result = self
        enumerateSubstrings(in: startIndex..<endIndex, options: .bySentences) { (subString, _, _, stop) in
            if let subString = subString, !subString.isEmpty {
                stop = true
                result = subString
            }
        }
        return result
    }

    func styledHtmlAttributed(fontSize: CGFloat, color: UIColor) -> NSAttributedString {
        let htmlString = self.styledHtmlString(fontSize: fontSize, color: color)
        return htmlString.htmlAttributed()
    }
}

private extension UIColor {
    var hexString: String {
        let cgColorInRGB = cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)!
        let colorRef = cgColorInRGB.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha

        var color = String(
            format: "%02X%02X%02X",
            (Int)(r * 255),
            (Int)(g * 255),
            (Int)(b * 255)
        )

        if a < 1 {
            color += String(format: "%02X", Int(a * 255))
        }

        return color
    }
}
