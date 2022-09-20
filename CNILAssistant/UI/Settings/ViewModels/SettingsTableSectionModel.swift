import Foundation
import RxRelay
import RxDataSources

protocol SettingItem {
    var title: String { get }
}

protocol SelectableSettingItem {
    var canSelect: Bool { get }
    func select()
}

class TitleSettingItem: SettingItem, SelectableSettingItem {
    let title: String
    let isSelectable: Bool
    let isEnabled: Bool
    let onSelected: (() -> Void)?

    init(title: String, isSelectable: Bool = true, isEnabled: Bool = true, onSelected: (() -> Void)? = nil) {
        self.title = title
        self.isSelectable = isSelectable
        self.isEnabled = isEnabled
        self.onSelected = onSelected
    }

    var canSelect: Bool {
        isSelectable && isEnabled
    }

    func select() {
        onSelected?()
    }
}

class TitleDetailsSettingItem: SettingItem, SelectableSettingItem {
    let title: String
    let details: String
    let isSelectable: Bool
    let isEnabled: Bool
    let onSelected: (() -> Void)?

    init(title: String, details: String, isSelectable: Bool = true, isEnabled: Bool = true, onSelected: (() -> Void)? = nil) {
        self.title = title
        self.details = details
        self.isSelectable = isSelectable
        self.isEnabled = isEnabled
        self.onSelected = onSelected
    }

    var canSelect: Bool {
        isSelectable && isEnabled
    }

    func select() {
        onSelected?()
    }
 }

class InfoSettingItem: SettingItem {
    let title: String
    let details: String

    init(title: String, details: String) {
        self.title = title
        self.details = details
    }
}

class BoolSettingItem: SettingItem {
    init(title: String, isOn: Bool, isEnabled: Bool = true, onChanged: ((Bool) -> Void)?) {
        self.title = title
        self.isOn = isOn
        self.isEnabled = isEnabled
        self.onChanged = onChanged
    }

    let title: String
    private(set) var isOn: Bool
    let isEnabled: Bool
    let onChanged: ((Bool) -> Void)?
    func changeValue(isOn: Bool) {
        self.isOn = isOn
        onChanged?(isOn)
    }
}

struct SettingsTableSectionModel {
    var title: String
    var items: [SettingItem]
}

extension SettingsTableSectionModel: SectionModelType {
    typealias Item = SettingItem

    init(original: SettingsTableSectionModel, items: [SettingItem]) {
        self = original
        self.items = items
    }
}
