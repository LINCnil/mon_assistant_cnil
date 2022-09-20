

import Foundation

struct QuestionDto: Decodable {
    let id: String
    let names: [QuestionNameDto]
    let metadata: [QuestionMetadataDto]

    enum CodingKeys: String, CodingKey {
        case id
        case names
        case metadata
    }
}

struct QuestionNameDto: Decodable {
    let locale: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case locale
        case name
    }
}

struct QuestionMetadataDto: Decodable {
    let locale: String
    let content: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case locale
        case content
        case name
    }
}
