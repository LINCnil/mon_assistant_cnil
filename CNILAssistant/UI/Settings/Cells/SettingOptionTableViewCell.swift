import UIKit

class SettingOptionTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!

    static let nib = UINib(nibName: typeName, bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.title)
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
