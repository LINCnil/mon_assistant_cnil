import Foundation

enum DataSource {
    case audioFile(url: URL)
    case text(text: String)
}
