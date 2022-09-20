

import UIKit

class EstimatedHeightHelperTableViewDelegate: NSObject, UITableViewDelegate {
    private var estimatedHeightAtIndexPath: [IndexPath: CGFloat] = [:]

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        estimatedHeightAtIndexPath[indexPath] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = estimatedHeightAtIndexPath[indexPath] {
            return height
        }
        return tableView.estimatedRowHeight
    }
}
