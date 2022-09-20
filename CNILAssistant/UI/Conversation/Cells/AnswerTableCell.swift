import Foundation
import UIKit
import RxSwift

class AnswerTableCell: UITableViewCell {
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var answerLabel: UILabel!

    private var viewModel: AnswerEntryViewModel?

    static let nib = UINib(nibName: typeName, bundle: nil)

    private var disposeBag: DisposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        questionLabel.applyStyle(.conversationQuestionMessage)
        answerLabel.applyStyle(.conversationAnswerMessage)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        viewModel = nil
    }

    func configure(viewModel: AnswerEntryViewModel) {
        disposeBag = DisposeBag()
        self.viewModel = viewModel

        questionLabel.text = viewModel.questionText
        answerLabel.text = viewModel.answerHtmlBody.htmlAttributed().string
    }
}
