

import Foundation
import AVFoundation
import MobileCoreServices

extension AVFileType {
    /// Fetch and extension for a file from UTI string
    var fileExtension: String? {
        if let ext = UTTypeCopyPreferredTagWithClass(self as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() {
            return ext as String
        }
        return nil
    }
}
