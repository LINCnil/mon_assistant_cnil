

import Foundation

protocol ModelsRepository {
    func getLatestModelVersion(completion: @escaping (Result<RemoteModel, Error>) -> Void)
    func download(model: RemoteModel, to directory: URL, completion: @escaping (Result<URL, Error>) -> Void)
}
