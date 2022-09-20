import UIKit

class PipelineLogTableCell: UITableViewCell {
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var tagLabel: UILabel!

    static let nib = UINib(nibName: typeName, bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .app_background
        tagLabel.applyStyle(.header)
        contentLabel.applyStyle(.details)
        timestampLabel.applyStyle(.caption)
    }

    func configure(viewModel: PipelineLogEntryViewModel) {
        timestampLabel.text = viewModel.timestamp
        contentLabel.text = viewModel.content
        tagLabel.text = viewModel.tag
    }
}
