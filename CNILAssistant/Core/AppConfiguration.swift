
import Foundation

enum AppConfiguration {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    static let hostUrl: URL = {
        guard let serverURLstring = Self.infoDictionary["SERVER_URL"] as? String else {
            fatalError("SERVER_URL not set in plist for this environment")
        }
        guard let url = URL(string: serverURLstring) else {
            fatalError("SERVER_URL is invalid")
        }
        return url
    }()

    static let supportedModelArchVersion: Decimal = {
        guard let version = Self.infoDictionary["SUPPORTED_ARCH_MODEL_VERSION"] as? String else {
            fatalError("SUPPORTED_ARCH_MODEL_VERSION not set in plist for this environment")
        }
        guard let versionNumber = Decimal(string: version) else {
            fatalError("SUPPORTED_ARCH_MODEL_VERSION is invalid")
        }
        return versionNumber
    }()

    static let clientCertificateUrl: URL = {
        guard let fileName = Self.infoDictionary["CLIENT_CERTIFICATE_FILE_NAME"] as? String else {
            fatalError("CLIENT_CERTIFICATE_FILE_NAME not set in plist for this environment")
        }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "pfx") else {
            fatalError("CLIENT_CERTIFICATE_FILE_NAME is not exists in main bundle")
        }
        return url
    }()

    // To avoid using string literal contains sensetive information, using AES encrypted byte array
    // To produce byte array for new password, use following call
    // print(AESEncryption.encrypt(data: "SomeNewPassword".data(using: .utf8)!).map { String(format: "%02x", $0) }.joined())
    static let clientCertificatePassphrase: String = {
        guard let hexString = Self.infoDictionary["CLIENT_CERTIFICATE_PASSPHRASE_HEX"] as? String else {
            fatalError("CLIENT_CERTIFICATE_PASSPHRASE_HEX not set in plist for this environment")
        }
        guard let encoded = try? hexString.asHexArray(),
              let passphrase = String(data: AESEncryption.decrypt(data: Data(encoded)), encoding: .utf8) else {
            fatalError("CLIENT_CERTIFICATE_PASSPHRASE_HEX is invalid")
        }
        return passphrase
    }()
}
