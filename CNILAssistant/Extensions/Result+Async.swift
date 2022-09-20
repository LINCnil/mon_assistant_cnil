

import Foundation

extension Result {
    func asyncMap<NewSuccess>(
        transform: @escaping (_ success: Success, _ completion: @escaping (Result<NewSuccess, Error>) -> Void) -> Void,
        completion: @escaping (Result<NewSuccess, Error>) -> Void) {

        switch self {
        case .success(let success):
            transform(success, completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
