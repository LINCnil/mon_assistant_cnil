
import Foundation
import Swinject

class RepositoriesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PipelineLogRepository.self) { _ in
            InMemoryPipelineLogRepositoryImplemention.current
        }.inObjectScope(.container)

        container.register(BookmarksRepository.self) { _ in
            BookmarksUserDefaultsRepositoryImplementation()
        }.inObjectScope(.container)

        container.register(ModelsRepository.self) { r in
            ModelsRepositoryImplementation(
                httpClient: r.resolve(RestHttpClient.self)!
            )
        }.inObjectScope(.container)
    }
}
