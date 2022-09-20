
import Foundation

extension DateFormatter {
    static let logDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    static let fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
}
