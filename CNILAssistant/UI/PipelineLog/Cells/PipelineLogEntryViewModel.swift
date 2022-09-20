
import Foundation

class PipelineLogEntryViewModel {
    private let log: PipelineLog

    var timestamp: String {
        return DateFormatter.logDateFormatter.string(from: log.date)
    }

    var content: String {
        return log.entry
    }

    var tag: String {
        return log.tag.rawValue
    }

    init(log: PipelineLog) {
        self.log = log
    }
}
