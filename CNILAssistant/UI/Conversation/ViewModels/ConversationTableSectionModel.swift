
import Foundation
import RxDataSources

struct ConversationTableSectionModel<ItemViewModel> {
    var items: [ItemViewModelHolder<ItemViewModel>]

    var identity: Int {
        return 0
    }

    mutating func set(_ items: [ItemViewModelHolder<ItemViewModel>]) {
        removeAll()
        for item in items {
            append(item)
        }
    }

    mutating func append(_ element: ItemViewModelHolder<ItemViewModel>) {
        items.append(element)
    }

    mutating func append(_ items: [ItemViewModelHolder<ItemViewModel>]) {
        for element in items {
            append(element)
        }
    }

    mutating func removeAll() {
        items.removeAll()
    }

    mutating func remove(element: ItemViewModelHolder<ItemViewModel>) {
        if let index = items.firstIndex(of: element) {
            items.remove(at: index)
        }
    }

    mutating func replace(element: ItemViewModelHolder<ItemViewModel>, with newElement: ItemViewModelHolder<ItemViewModel>) {
        if let index = items.firstIndex(of: element) {
            items.remove(at: index)
            items.insert(newElement, at: index)
        }
    }
}

extension ConversationTableSectionModel: AnimatableSectionModelType {
    typealias Identity = Int
    typealias Item = ItemViewModelHolder<ItemViewModel>

    init(original: ConversationTableSectionModel, items: [ItemViewModelHolder<ItemViewModel>]) {
        self = original
        self.items = items
    }
}

extension ItemViewModelHolder: IdentifiableType, Equatable {
    static func == (lhs: ItemViewModelHolder, rhs: ItemViewModelHolder) -> Bool {
        return lhs.identity == rhs.identity
    }

    typealias Identity = Int

    var identity: Identity {
        return uuid.hashValue
    }
}

class ItemViewModelHolder<ViewModel> {
    let uuid: UUID
    let viewModel: ViewModel

    convenience init(configure: (UUID) -> ViewModel) {
        let uuid = UUID()
        self.init(uuid: uuid, viewModel: configure(uuid))
    }

    convenience init(viewModel: ViewModel) {
        self.init(uuid: UUID(), viewModel: viewModel)
    }

    private init(uuid: UUID, viewModel: ViewModel) {
        self.uuid = uuid
        self.viewModel = viewModel
    }
}
