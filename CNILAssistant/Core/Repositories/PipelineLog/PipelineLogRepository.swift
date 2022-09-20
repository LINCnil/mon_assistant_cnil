

import Foundation
import HybridNlpEngine

protocol PipelineLogRepository {
    func log(entry: String, for tag: PipelineLog.Tag)
    func getAll(completion: @escaping (Result<[PipelineLog], Error>) -> Void)
    func removeAll()
}
