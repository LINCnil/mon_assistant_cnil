import UIKit

class TitleRightDetailsTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!

    static let nib = UINib(nibName: typeName, bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.title)
        detailsLabel.applyStyle(.details)
    }

    func configure(viewModel: TitleDetailsSettingItem) {
        titleLabel.text = viewModel.title
        detailsLabel.text = viewModel.details
        accessoryType = viewModel.isSelectable ? .disclosureIndicator : .none
        selectionStyle = viewModel.isSelectable ? .default : .none
    }
}
