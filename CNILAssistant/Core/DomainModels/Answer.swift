import Foundation

struct Answer {
    let userQuestion: String
    let proposals: [AnswerContent]
}

struct AnswerContent {
    let id: Int
    let htmlBody: String
    let question: String
    let keywords: [String]
}
