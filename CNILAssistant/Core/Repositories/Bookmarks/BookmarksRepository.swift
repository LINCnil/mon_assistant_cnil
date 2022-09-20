

import Foundation

protocol BookmarksRepository {
    func add(answerId: Int)
    func remove(answerId: Int)
    func contains(answerId: Int) -> Bool
    func getAll() -> [Int]
    func removeAll()
}
