import Foundation
import Alamofire

struct PfxCertificateInfo {
    var path: URL
    var passphrase: String
    init(path: URL, passphrase: String) {
        self.path = path
        self.passphrase = passphrase
    }
}

enum HttpClientError: Error {
    case invalidUrl(hostUrl: URL)
    case invalidClientCertificate(path: URL)
}

class RestHttpClient {
    private let session: Session
    private let urlCredential: URLCredential
    private let hostUrl: URL

    init(hostUrl: URL, clientCertificate: PfxCertificateInfo) throws {
        guard let host = hostUrl.host else {
            throw HttpClientError.invalidUrl(hostUrl: hostUrl)
        }

        self.hostUrl = hostUrl

        let localCertData = try Data(contentsOf: clientCertificate.path) as NSData

        guard let identityAndTrust = Self.extractIdentity(certData: localCertData, certPassword: clientCertificate.passphrase) else {
            throw HttpClientError.invalidClientCertificate(path: clientCertificate.path)
        }

        urlCredential = URLCredential(
                        identity: identityAndTrust.identityRef,
                        certificates: identityAndTrust.certArray as [AnyObject],
                        persistence: URLCredential.Persistence.forSession)

        let trustManager = ServerTrustManager(
            evaluators: [
                host: PublicKeysTrustEvaluator(
                    keys: Bundle.main.af.publicKeys,
                    performDefaultValidation: false,
                    validateHost: false)
            ])

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30

        session = Session(configuration: configuration, serverTrustManager: trustManager)
    }

    func performRoute<T: Decodable>(_ route: String, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        session.request(hostUrl.appendingPathComponent(route))
            .authenticate(with: urlCredential)
            .responseDecodable(of: responseType) { response in
                completion(response.result.mapError { $0 as Error })
        }
    }

    func downloadFile(at path: String, to url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let destination: DownloadRequest.Destination = { _, _ in
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }

        session.download(hostUrl.appendingPathComponent(path), to: destination)
            .authenticate(with: urlCredential)
            .responseURL { response in
                completion(response.result.mapError { $0 as Error })
        }
    }

    deinit {
        session.cancelAllRequests()
    }

    private struct IdentityAndTrust {
        var identityRef: SecIdentity
        var trust: SecTrust
        var certArray: NSArray
    }

    private static func extractIdentity(certData: NSData, certPassword: String) -> IdentityAndTrust? {
        var identityAndTrust: IdentityAndTrust?
        var securityError: OSStatus = errSecSuccess

        var items: CFArray?
        let certOptions: Dictionary = [kSecImportExportPassphrase as String: certPassword]
        // import certificate to read its entries
        securityError = SecPKCS12Import(certData, certOptions as CFDictionary, &items)
        if securityError == errSecSuccess {

            let certItems: CFArray = items!
            let certItemsArray: Array = certItems as Array
            let dict: AnyObject? = certItemsArray.first

            if let certEntry: Dictionary = dict as? [String: AnyObject] {

                // grab the identity
                let identityPointer: AnyObject? = certEntry["identity"]
                let secIdentityRef: SecIdentity = identityPointer as! SecIdentity

                // grab the trust
                let trustPointer: AnyObject? = certEntry["trust"]
                let trustRef: SecTrust = trustPointer as! SecTrust

                // grab the certificate chain
                var certRef: SecCertificate?
                SecIdentityCopyCertificate(secIdentityRef, &certRef)
                let certArray: NSMutableArray = NSMutableArray()
                certArray.add(certRef!)

                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray: certArray)
            }
        }
        return identityAndTrust
    }
}
