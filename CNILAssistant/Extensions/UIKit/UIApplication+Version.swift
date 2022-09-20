

import Foundation
import UIKit

public extension UIApplication {
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    static var buildVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }

    static var formattedFullVersion: String {
        "\(appVersion) (\(Int(buildVersion)!))"
    }
}
