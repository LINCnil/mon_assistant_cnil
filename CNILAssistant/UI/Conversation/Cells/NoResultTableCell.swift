
import UIKit

class NoResultTableCell: UITableViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!

    static let nib = UINib(nibName: typeName, bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.header)
        messageLabel.applyStyle(.details)

        iconImageView.applyStyle(.tintedImage(.app_nothingFoundIcon, tintColor: .app_buttonTint))
    }

    func configure(viewModel: NoResultEntryViewModel) {
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.content
    }
}
