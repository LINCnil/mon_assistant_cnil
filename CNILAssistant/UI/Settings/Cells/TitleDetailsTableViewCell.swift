import UIKit

class TitleDetailsTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!

    static let nib = UINib(nibName: typeName, bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.title)
        detailsLabel.applyStyle(.accent)
    }

    func configure(viewModel: InfoSettingItem) {
        titleLabel.text = viewModel.title
        detailsLabel.text = viewModel.details
        selectionStyle = .none
    }
}
