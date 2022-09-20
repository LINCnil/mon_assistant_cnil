

import Foundation

struct AnswerDto: Decodable {
    let id: String
    let contents: [AnswerContentDto]

    enum CodingKeys: String, CodingKey {
        case id
        case contents
    }
}

struct AnswerContentDto: Decodable {
    let locale: String
    let content: String
    let format: String

    enum CodingKeys: String, CodingKey {
        case locale
        case content
        case format
    }
}
