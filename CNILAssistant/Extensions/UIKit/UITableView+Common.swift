
import Foundation
import UIKit

extension UITableView {
    func sizeTableHeaderToFit() {
        guard let headerView = self.tableHeaderView else {
            return
        }

        headerView.translatesAutoresizingMaskIntoConstraints = false

        let temporaryWidthConstraint = NSLayoutConstraint(
            item: headerView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: headerView.bounds.size.width)
        headerView.addConstraint(temporaryWidthConstraint)

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size = CGSize(width: frame.width, height: height)
        headerView.frame = frame
        self.tableHeaderView = headerView

        headerView.removeConstraint(temporaryWidthConstraint)
        headerView.translatesAutoresizingMaskIntoConstraints = true
    }

    func sizeTableFooterToFit() {
        guard let footerView = self.tableFooterView else {
            return
        }

        footerView.translatesAutoresizingMaskIntoConstraints = false

        let temporaryWidthConstraint = NSLayoutConstraint(
            item: footerView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: footerView.bounds.size.width)
        footerView.addConstraint(temporaryWidthConstraint)

        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()

        let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = footerView.frame
        frame.size = CGSize(width: frame.width, height: height)
        footerView.frame = frame
        self.tableFooterView = footerView

        footerView.removeConstraint(temporaryWidthConstraint)
        footerView.translatesAutoresizingMaskIntoConstraints = true
    }
}
