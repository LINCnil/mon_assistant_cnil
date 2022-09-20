
import Foundation

enum HexConvertError: Error {
    case invalidInputStringLength
    case invalidInputStringCharacters
}

extension StringProtocol {
    func asHexArrayFromNonValidatedSource() -> [UInt8] {
        var startIndex = self.startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }

    func asHexArray() throws -> [UInt8] {
        if count % 2 != 0 { throw HexConvertError.invalidInputStringLength }
        let characterSet = "0123456789ABCDEFabcdef"
        let wrongCharacter = first { return !characterSet.contains($0) }
        if wrongCharacter != nil { throw HexConvertError.invalidInputStringCharacters }
        return asHexArrayFromNonValidatedSource()
    }
}
