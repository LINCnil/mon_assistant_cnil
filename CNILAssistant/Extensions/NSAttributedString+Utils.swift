

import Foundation

extension NSAttributedString {

    func trim() -> NSAttributedString {
        return attributedStringByTrimmingCharacter(in: .whitespacesAndNewlines)
    }

    func attributedStringByTrimmingCharacter(in characterSet: CharacterSet) -> NSAttributedString {
        let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharacters(in: characterSet)
        return NSAttributedString(attributedString: modifiedString)
    }
}

extension NSMutableAttributedString {
    func trimCharacters(in characterSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: characterSet)

        // Trim leading characters from character set.
        while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: characterSet)
        }

        // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: characterSet, options: .backwards)
        while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: characterSet, options: .backwards)
        }
    }
}
