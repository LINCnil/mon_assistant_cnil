
import Foundation
import Swinject

extension ObjectScope {
    static let modelRelated = ObjectScope(
        storageFactory: PermanentStorage.init,
        description: "modelRelated"
    )
}
