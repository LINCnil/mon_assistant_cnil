

import Foundation
import Swinject

class DependencyProvider {

    static let shared = DependencyProvider()

    private let container = Container()
    private let assembler: Assembler

    private init() {
        assembler = Assembler([
            HandlersAssembly(),
            ClientsAssembly(),
            RepositoriesAssembly(),
            ServicesAssembly(),
            ProvidersAssembly()
        ], container: container)
    }

    // MARK: - Services

    func processingService() throws -> ProcessingService {
        return try assembler
            .resolver
            .throwsResolve(ProcessingService.self)
    }

    #if !PROD
    func pipelineLogRepository() -> PipelineLogRepository {
        return assembler
            .resolver
            .resolve(PipelineLogRepository.self)!
    }
    #endif

    func answerRepository() -> AnswerRepository {
        return assembler
            .resolver
            .resolve(AnswerRepository.self)!
    }

    func bookmarksRepository() -> BookmarksRepository {
        return assembler
            .resolver
            .resolve(BookmarksRepository.self)!
    }

    func modelProvider() -> ModelProvider {
        return assembler
            .resolver
            .resolve(ModelProvider.self)!
    }

    func loadModelRelatedObjects(modelDescription: ModelDescription) {
        let assembly = ModelRelatedAssembly(modelDescription: modelDescription)
        assembler.apply(assembly: assembly)
    }

    func resetModelRelatedObjects() {
        container.resetObjectScope(.modelRelated)
    }
}
