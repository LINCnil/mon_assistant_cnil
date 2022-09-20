import UIKit

class TitleSwitchTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueSwitch: UISwitch!

    static let nib = UINib(nibName: typeName, bundle: nil)

    private var viewModel: BoolSettingItem?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.title)
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }

    func configure(viewModel: BoolSettingItem) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        valueSwitch.isOn = viewModel.isOn
        valueSwitch.isEnabled = viewModel.isEnabled

    }

    @IBAction
    private func onValueChanged(_ sender: UISwitch) {
        if let viewModel = self.viewModel {
            viewModel.changeValue(isOn: sender.isOn)
        }
    }
}
