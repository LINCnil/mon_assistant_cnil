import Foundation

struct PipelineLog {
    enum Tag: String {
        case common = "COMMON"
        case stt = "STT"
        case nlp = "NLP"
        case db  = "DB"
        case tts = "TTS"
    }

    let date: Date
    let tag: Tag
    let entry: String
}
