
import Foundation

extension Array {
    func first(or thrower: () -> Error) throws -> Element {
        if let first = self.first {
            return first
        } else {
            throw thrower()
        }
    }
}
