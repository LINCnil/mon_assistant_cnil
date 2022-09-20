import Foundation
import NaturalLanguage
import HybridNlpEngine

final class NLTokenizerImplemention: Tokenizer {
    private let language: NLLanguage
    init(language: NLLanguage) {
        self.language = language
    }

    func tokenize(text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.setLanguage(language)
        tokenizer.string = text

        var result: [String] = []

        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let token = String(text[tokenRange])
            result.append(token)
            return true
        }

        return result
    }
}
