
import Foundation
import Swinject

// swiftlint:disable force_try
class ClientsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(RestHttpClient.self) { _ in
            return try! RestHttpClient(
                hostUrl: AppConfiguration.hostUrl,
                clientCertificate: PfxCertificateInfo(
                    path: AppConfiguration.clientCertificateUrl,
                    passphrase: AppConfiguration.clientCertificatePassphrase))
        }.inObjectScope(.container)
    }
}
