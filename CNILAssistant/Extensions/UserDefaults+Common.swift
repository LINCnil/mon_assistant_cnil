
import Foundation

public extension UserDefaults {
    func integer(forKey defaultName: String, or defaultValue: Int) -> Int {
        if self.object(forKey: defaultName) != nil {
            return self.integer(forKey: defaultName)
        }
        return defaultValue
    }

    func float(forKey defaultName: String, or defaultValue: Float) -> Float {
        if self.object(forKey: defaultName) != nil {
            return self.float(forKey: defaultName)
        }
        return defaultValue
    }

    func double(forKey defaultName: String, or defaultValue: Double) -> Double {
        if self.object(forKey: defaultName) != nil {
            return self.double(forKey: defaultName)
        }
        return defaultValue
    }

    func bool(forKey defaultName: String, or defaultValue: Bool) -> Bool {
        if self.object(forKey: defaultName) != nil {
            return self.bool(forKey: defaultName)
        }
        return defaultValue
    }
}
