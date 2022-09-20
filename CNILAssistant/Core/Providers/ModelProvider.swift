

import Foundation
import Zip
import HybridNlpEngine

enum ModelProviderError: Error {
    case invalidModelDescription
    case unsupportedModelArch(actual: Decimal, expected: Decimal)
}

extension ModelProviderError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidModelDescription:
            return "Invalid model description"
        case let .unsupportedModelArch(actual, expected):
            return "Trying to install unsupported model version, actual: \(actual) expected: \(expected)"
        }
    }
}

private struct ModelConfigDto: Decodable {
    let keywords: String
    let classesMap: String
    let stopwords: String
    let vocab: String
    let nlpModel: String
    let allDataset: String
    let version: String
    let sttModel: String
    let crunchfile: String
    let testResults: String

    enum CodingKeys: String, CodingKey {
        case keywords
        case classesMap = "classes_map"
        case stopwords
        case vocab
        case nlpModel
        case allDataset = "all_dataset"
        case version = "update_package_version"
        case sttModel
        case crunchfile
        case testResults = "test_result"
    }
}

class ModelProvider {
    let embeddedModelUrl: URL
    let embeddedModelVersion: ModelVersion
    let embeddedSttMainModelUrl: URL

    private let modelDirectory: URL
    private let workingDirectory: URL
    var installedModel: ModelDescription?
    private let modelsRepository: ModelsRepository

    init(modelsRepository: ModelsRepository, bundle: Bundle) {
        self.modelsRepository = modelsRepository
        self.modelDirectory = FileManager.default.getDocumentsDirectory().appendingPathComponent("model")
        self.workingDirectory = FileManager.default.getCachesDirectory().appendingPathComponent("working")

        embeddedModelUrl = bundle.urls(forResourcesWithExtension: "zip", subdirectory: "EmbeddedModel")!.first!
        embeddedModelVersion = ModelVersion(versionName: embeddedModelUrl.deletingPathExtension().lastPathComponent)
        embeddedSttMainModelUrl =  bundle.urls(forResourcesWithExtension: "tflite", subdirectory: "EmbeddedModel")!.first!

        installedModel = try? getModelDescription(from: self.modelDirectory)
    }

    func downloadAndInstall(model: RemoteModel, completion: @escaping (Result<ModelDescription, Error>) -> Void) {
        modelsRepository.download(model: model, to: workingDirectory) {
            $0.asyncMap(transform: { url, completion in
                self.installModel(from: url) { modelDescription in
                    try? FileManager.default.removeItem(at: url)
                    completion(modelDescription)
                }
            }, completion: completion)
        }
    }

    func installModel(from url: URL, completion: @escaping (Result<ModelDescription, Error>) -> Void) {
        DispatchQueue.global().async {
            let result: Result<ModelDescription, Error>

            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }

            do {
                try self.performInstallModel(from: url)
                let modelDescription = try self.getModelDescription(from: self.modelDirectory)
                self.installedModel = modelDescription
                result = .success(modelDescription)
            } catch {
                result = .failure(error)
            }
        }
    }

    func checkForUpdate(completion: @escaping (Result<RemoteModel, Error>) -> Void) {
        modelsRepository.getLatestModelVersion(completion: completion)
    }

    private func performInstallModel(from url: URL) throws {
        let unzipDirectory = workingDirectory.appendingPathComponent(url.deletingPathExtension().lastPathComponent)

        defer {
            try? FileManager.default.removeItem(at: unzipDirectory)
        }

        try Zip.unzipFile(url, destination: unzipDirectory, overwrite: true, password: nil, progress: nil)

        let newModelDescription = try getModelDescription(from: unzipDirectory)

        guard newModelDescription.version.archVersion == AppConfiguration.supportedModelArchVersion else {
            throw ModelProviderError.unsupportedModelArch(
                actual: newModelDescription.version.archVersion,
                expected: AppConfiguration.supportedModelArchVersion)
        }

        try? FileManager.default.removeItem(at: modelDirectory)
        try FileManager.default.moveItem(at: unzipDirectory, to: modelDirectory)
    }

    private func getModelDescription(from url: URL) throws -> ModelDescription {
        let data = try Data(contentsOf: url.appendingPathComponent("config.json"))
        let config = try JSONDecoder().decode(ModelConfigDto.self, from: data)

        return ModelDescription(
            version: ModelVersion(versionName: config.version),
            nlp: ModelDescription.NlpDescription(
                tfModelFileUrl: url.appendingPathComponent(config.nlpModel),
                vocabFileUrl: url.appendingPathComponent(config.vocab),
                classesMapFileUrl: url.appendingPathComponent(config.classesMap),
                stopwordsFileUrl: url.appendingPathComponent(config.stopwords),
                keywordsFileUrl: url.appendingPathComponent(config.keywords),
                crunchFileUrl: url.appendingPathComponent(config.crunchfile),
                testResultFileUrl: url.appendingPathComponent(config.testResults),
                config: HybridTextClassifierConfiguration(maximumResultCount: 5)),
            stt: ModelDescription.SttDescription(
                tfModelFileUrl: embeddedSttMainModelUrl,
                scorerFileUrl: url.appendingPathComponent(config.sttModel)),
            questionsDirectory: url.appendingPathComponent(config.allDataset))
    }
}
