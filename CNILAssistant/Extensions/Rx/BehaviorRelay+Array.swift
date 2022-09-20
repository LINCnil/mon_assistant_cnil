
import Foundation
import RxCocoa

extension BehaviorRelay where Element: RangeReplaceableCollection {
    func add(element: Element.Element) {
        var array = self.value
        array.append(element)
        self.accept(array)
    }

    func add(elements: [Element.Element]) {
        var array = self.value
        array.append(contentsOf: elements)
        self.accept(array)
    }

    func replace(at i: Element.Index, element: Element.Element) {
        var array = self.value
        array.remove(at: i)
        array.insert(element, at: i)
        self.accept(array)
    }

    func set(elements: [Element.Element]) {
        var array = self.value
        array.removeAll()
        array.append(contentsOf: elements)
        self.accept(array)
    }
}
