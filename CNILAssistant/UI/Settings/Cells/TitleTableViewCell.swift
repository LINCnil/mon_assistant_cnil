import UIKit

class TitleTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!

    static let nib = UINib(nibName: typeName, bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.title)
    }

    func configure(viewModel: TitleSettingItem) {
        titleLabel.text = viewModel.title
        accessoryType = viewModel.isSelectable ? .disclosureIndicator : .none
        selectionStyle = viewModel.isSelectable ? .default : .none
    }
}
