
import Foundation

// swiftlint:disable type_name
final class BookmarksUserDefaultsRepositoryImplementation: BookmarksRepository {
    private let bookmarksIdsKey = "BookmarksIds"

    init() {
    }

    // MARK: - BookmarksRepository

    func add(answerId: Int) {
        var ids = getIds()
        if !ids.contains(answerId) {
            ids.append(answerId)
            set(ids: ids)
        }
    }

    func remove(answerId: Int) {
        var ids = getIds()
        ids.removeAll(where: { answerId == $0 })
        set(ids: ids)
    }

    func contains(answerId: Int) -> Bool {
        let ids = getIds()
        return ids.contains(answerId)
    }

    func getAll() -> [Int] {
        return getIds()
    }

    func removeAll() {
        set(ids: [])
    }

    // MARK: - Private

    private func getIds() -> [Int] {
        return UserDefaults.standard.object(forKey: bookmarksIdsKey) as? [Int] ?? [Int]()
    }

    private func set(ids: [Int]) {
        UserDefaults.standard.set(ids, forKey: bookmarksIdsKey)
    }

    private func removeAllIds() {
        UserDefaults.standard.removeObject(forKey: bookmarksIdsKey)
    }
}
