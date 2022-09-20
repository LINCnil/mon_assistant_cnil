
import Foundation

// swiftlint:disable type_name
final class InMemoryPipelineLogRepositoryImplemention: PipelineLogRepository {
    private var logs: [PipelineLog] = []
    private let internalQueue = DispatchQueue(label: "inMemoryPipelineLogRepositoryImplemention.internalQueue")

    static let current = InMemoryPipelineLogRepositoryImplemention()

    private init() {
    }

    func log(entry: String, for tag: PipelineLog.Tag) {
        let log = PipelineLog(date: Date(), tag: tag, entry: entry)
        internalQueue.sync {
            self.logs.append(log)
        }
    }

    func getAll(completion: @escaping (Result<[PipelineLog], Error>) -> Void) {
        internalQueue.async {
            let logs = self.logs
            DispatchQueue.main.async {
                completion(.success(logs))
            }
        }
    }

    func removeAll() {
        internalQueue.sync {
            self.logs.removeAll()
        }
    }
}
