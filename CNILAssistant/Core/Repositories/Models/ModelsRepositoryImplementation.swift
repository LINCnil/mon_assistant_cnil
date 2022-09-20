
import Foundation
import CommonCrypto

final class ModelsRepositoryImplementation: ModelsRepository {
    private let httpClient: RestHttpClient

    init(httpClient: RestHttpClient) {
        self.httpClient = httpClient
    }

    func getLatestModelVersion(completion: @escaping (Result<RemoteModel, Error>) -> Void) {
        httpClient.performRoute("metadata/", responseType: ModelVersionDto.self) { r in
            completion(r.flatMap { dto -> Result<RemoteModel, Error> in
                do {
                    return .success(try ModelVersionMapper().map(versionDto: dto))
                } catch {
                    return .failure(error)
                }
            })
        }
    }

    func download(model: RemoteModel, to directory: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let destinationFileURL = directory.appendingPathComponent("\(model.version.fullName).zip")
        let sourceFileRelativePath = "models/\(model.version.fullName)/\(model.fileName)"
        httpClient.downloadFile(at: sourceFileRelativePath, to: destinationFileURL) { r in
            DispatchQueue.global().async {
                let result: Result<URL, Error>

                defer {
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }

                switch r {
                case .success(let url):
                    if let digestData = self.md5File(url: url) {
                        let calculatedHash = digestData.map { String(format: "%02hhx", $0) }.joined()
                        if calculatedHash == model.fileCheckSumm {
                            result = .success(url)
                            return
                        }
                    }
                    result = .failure(ModelsRepositoryError.checkSummMismatch(fileName: sourceFileRelativePath))
                case .failure(let error):
                    result = .failure(error)
                }
            }
        }
    }

    private func md5File(url: URL) -> Data? {
        let bufferSize = 1024 * 1024
        do {
            // Open file for reading:
            let file = try FileHandle(forReadingFrom: url)
            defer {
                file.closeFile()
            }

            // Create and initialize MD5 context:
            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)

            // Read up to `bufferSize` bytes, until EOF is reached, and update MD5 context:
            while autoreleasepool(invoking: {
                let data = file.readData(ofLength: bufferSize)
                if data.count > 0 {
                    data.withUnsafeBytes {
                        _ = CC_MD5_Update(&context, $0.baseAddress, numericCast(data.count))
                    }
                    return true // Continue
                } else {
                    return false // End of file
                }
            }) { }

            // Compute the MD5 digest:
            var digest: [UInt8] = Array(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            _ = CC_MD5_Final(&digest, &context)
            return Data(digest)
        } catch {
            print("Cannot open file:", error.localizedDescription)
            return nil
        }
    }
}
