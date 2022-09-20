
import Foundation

protocol ProcessingService {
    func processData(
        dataSource: DataSource,
        completion: @escaping (Result<Answer, Error>) -> Void)
}
