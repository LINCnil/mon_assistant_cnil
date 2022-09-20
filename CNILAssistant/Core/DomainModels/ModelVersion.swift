import Foundation

struct ModelVersion {
    let fullName: String
    var archVersion: Decimal {
        return Self.getModelArchVersion(versionName: fullName)
    }

    init(versionName: String) {
        self.fullName = versionName
    }

    private static func getModelArchVersion(versionName: String) -> Decimal {
        let pattern = "v(\\d+[\\.]\\d+)_"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: versionName, options: [], range: NSRange(versionName.startIndex..<versionName.endIndex, in: versionName)),
           let versionRange = Range(match.range(at: 1), in: versionName) {
            let archVersion = versionName[versionRange]
            return Decimal(string: String(archVersion)) ?? 1.0
        }
        return 1.0
    }
}

extension ModelVersion: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.fullName == rhs.fullName
    }
}
