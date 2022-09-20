

import Foundation
import UIKit
import RxSwift

extension Reactive where Base: UITableView {
    func emptyPlaceholder(emptyBacgroundView: UIView,
                          defaultBackgroundView: UIView?,
                          defaultSeparatorStyle: UITableViewCell.SeparatorStyle) -> Binder<Bool> {
        return Binder(base) { tableView, isShown in
            if isShown {
                tableView.backgroundView = emptyBacgroundView
                tableView.separatorStyle = .none
            } else {
                tableView.backgroundView = defaultBackgroundView
                tableView.separatorStyle = defaultSeparatorStyle
            }
        }
    }
}
