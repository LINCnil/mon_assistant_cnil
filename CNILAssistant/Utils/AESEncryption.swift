import Foundation
import CommonCrypto

struct AESEncryption {
    private init() { }

    // "12345678901234567890123456789012"
    private static let keyData = Data(
        [49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50])

    // "abcdefghijklmnop"
    private static let ivData = Data(
        [97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112])

    static func encrypt(data: Data) -> Data {
        crypt(data: data, operation: kCCEncrypt)
    }

    static func decrypt(data: Data) -> Data {
        crypt(data: data, operation: kCCDecrypt)
    }

    private static func crypt(data: Data, operation: Int) -> Data {
        let cryptLength = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptLength)

        let keyLength = size_t(kCCKeySizeAES128)
        let options = CCOptions(kCCOptionPKCS7Padding)

        var numBytesEncrypted: size_t = 0

        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                AESEncryption.ivData.withUnsafeBytes {ivBytes in
                    AESEncryption.keyData.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(operation),
                                  CCAlgorithm(kCCAlgorithmAES),
                                  options,
                                  keyBytes, keyLength,
                                  ivBytes,
                                  dataBytes, data.count,
                                  cryptBytes, cryptLength,
                                  &numBytesEncrypted)
                    }
                }
            }
        }

        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
        } else {
            print("Error: \(cryptStatus)")
        }

        return cryptData
    }
}
