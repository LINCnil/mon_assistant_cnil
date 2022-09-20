
import XCTest
import Foundation
import TensorFlowLite
import CodableCSV
import NaturalLanguage
import HybridNlpEngine
@testable import CNILAssistant

class MockModelsRepository: ModelsRepository {
    func getLatestModelVersion(completion: @escaping (Result<RemoteModel, Error>) -> Void) {
    }

    func download(model: RemoteModel, to directory: URL, completion: @escaping (Result<URL, Error>) -> Void) {
    }
}

class ValidateReferenceTestSetTests: XCTestCase {
    func testReferenceTestSet() throws {
        let completionExpectation = XCTestExpectation(description: "Completion")

        let inputColumnName = "augmentation"
        let outputColumnName = "hybrid_top_pred_orig_class"

        let mockRepository = MockModelsRepository()
        let modelProvider = ModelProvider(modelsRepository: mockRepository, bundle: Bundle.testBundle)

        let semaphore = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            modelProvider.installModel(from: modelProvider.embeddedModelUrl) { res in
                semaphore.signal()
            }
            semaphore.wait()

            let classifier = try! HybridTextClassifierImplemention(
                modelFileUrl: modelProvider.installedModel!.nlp.tfModelFileUrl,
                tokensMapFileUrl: modelProvider.installedModel!.nlp.vocabFileUrl,
                stopwordsFileUrl: modelProvider.installedModel!.nlp.stopwordsFileUrl,
                keywordsFileUrl: modelProvider.installedModel!.nlp.keywordsFileUrl,
                classesMapFileUrl: modelProvider.installedModel!.nlp.classesMapFileUrl,
                crunchFileUrl: modelProvider.installedModel!.nlp.crunchFileUrl,
                config: HybridTextClassifierConfiguration(maximumResultCount: 5),
                tokenizer: NLTokenizerImplemention(language: NLLanguage.french),
                locale: Locale(identifier: "fr"),
                processLogger: nil)

            let data = try! Data(contentsOf: modelProvider.installedModel!.nlp.testResultFileUrl)
            let reader = try! CSVReader(input: data) { $0.headerStrategy = .firstLine }

            while let record = try? reader.readRecord() {
                if let textToTest = record[inputColumnName], let expectedResults = record[outputColumnName] {
                    let expectedClasses = expectedResults.split(separator: ",").map { Int($0.trimmingCharacters(in: .whitespaces))! }
                    classifier.classify(text: textToTest) { result in
                        switch result {
                        case .success(let classes):
                            XCTAssert(expectedClasses == classes, "Result is not expected\nText: \(textToTest)\nExpected: \(expectedClasses)\nActual: \(classes)")
                        case .failure(let error):
                            switch error {
                            case ClassifierError.noResults(_):
                                XCTAssert(expectedClasses.isEmpty, "Result is not expected\nText: \(textToTest)\nExpected: \(expectedClasses)\nActual: \([])")
                            default:
                                XCTFail("Classification failed for \(textToTest) with error \(error.localizedDescription)")
                            }
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                } else {
                    XCTFail("Invalid input or output columns data")
                }
            }

            completionExpectation.fulfill()
        }

        wait(for: [completionExpectation], timeout: 60)
    }
}
