
import Foundation
import Swinject

class ProvidersAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ModelProvider.self) { r in
            ModelProvider(
                modelsRepository: r.resolve(ModelsRepository.self)!,
                bundle: r.resolve(Bundle.self)!
            )
        }.inObjectScope(.container)
    }
}
