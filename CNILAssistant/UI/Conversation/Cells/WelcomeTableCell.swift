import Foundation
import UIKit
import RxSwift
import Action

class WelcomeTableCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var suggestionsStackView: UIStackView!

    static let nib = UINib(nibName: typeName, bundle: nil)

    private var disposeBag: DisposeBag = DisposeBag()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }

        // To apply cgcolor
        suggestionsStackView.subviews.compactMap { $0 as? UIButton }.forEach { $0.applyStyle(.conversationOptionButton) }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        suggestionsStackView.removeAllArrangedSubviews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(.header)
        messageLabel.applyStyle(.text)
    }

    func configure(viewModel: WelcomeEntryViewModel) {
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.content

        for suggestion in viewModel.suggestionsQuestions {
            var button = UIButton(style: .conversationOptionButton)
            button.layer.masksToBounds = true
            button.setTitle(suggestion.title, for: .normal)

            button.rx.action = suggestion.select

            button.snp.makeConstraints { (make) -> Void in
                make.top.bottom.equalTo(button.titleLabel!).inset(-8)
                make.leading.trailing.equalTo(button.titleLabel!).inset(-8)
            }

            suggestionsStackView.addArrangedSubview(button)
        }
    }
}
