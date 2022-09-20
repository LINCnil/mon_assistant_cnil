

import Foundation
import Swinject

extension Resolver {
    func throwsResolve<Service>(_ serviceType: Service.Type) throws -> Service {
        switch resolve(Result<Service, Error>.self) {
        case .success(let service):
            return service
        case .failure(let error):
            throw error
        default:
            fatalError("Throwing version is not registered")
        }
    }

}
