import Foundation
import HybridNlpEngine

struct ModelDescription {
    struct NlpDescription {
        let tfModelFileUrl: URL
        let vocabFileUrl: URL
        let classesMapFileUrl: URL
        let stopwordsFileUrl: URL
        let keywordsFileUrl: URL
        let crunchFileUrl: URL
        let testResultFileUrl: URL

        let config: HybridTextClassifierConfiguration
    }

    struct SttDescription {
        let tfModelFileUrl: URL
        let scorerFileUrl: URL
    }

    let version: ModelVersion
    let nlp: NlpDescription
    let stt: SttDescription
    let questionsDirectory: URL
}
