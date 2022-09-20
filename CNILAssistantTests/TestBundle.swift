import Foundation

private class BundleToken {
}

extension Bundle {
    static let testBundle = Bundle(for: BundleToken.self)
}
