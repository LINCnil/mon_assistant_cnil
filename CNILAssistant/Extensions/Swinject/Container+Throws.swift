

import Foundation
import Swinject

extension Container {
    func throwsRegister<Service>(
        _ serviceType: Service.Type,
        name: String? = nil,
        factory: @escaping (Resolver) throws -> Service
    ) -> ServiceEntry<Result<Service, Error>> {
        register(Result<Service, Error>.self) { r in
            do {
                return .success(try factory(r))
            } catch {
                return .failure(error)
            }
        }
    }
}
