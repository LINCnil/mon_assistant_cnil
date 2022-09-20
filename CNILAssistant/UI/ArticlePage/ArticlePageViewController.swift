

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxDataSources

private class NoSpeakTextView: UITextView {
    convenience init(style: ViewStyle<UITextView>) {
        self.init()
        style.style(self)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == Selector(("_accessibilitySpeak:")) ||
            action == Selector(("_accessibilitySpeakLanguageSelection:")) ||
            action == Selector(("_accessibilityPauseSpeaking:")) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

class ArticlePageViewController: BaseViewController<ArticlePageViewModel> {
    private var tableView: UITableView!
    private var answerHeaderView: UIView!
    private var questionTextView: UITextView!
    private var answerTextView: UITextView!

    private var returnToSearchFooterView: UIView!
    private var returnToSearchFooterLabel: UILabel!

    private var speekingButton: UIBarButtonItem!
    private var bookmarkButton: UIBarButtonItem!

    private let styleChanged = PublishSubject<Void>()
    private let disposeBag = DisposeBag()

    override func loadView() {
        super.loadView()

        view.backgroundColor = .app_background

        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .app_separator
        tableView.backgroundColor = .app_background

        answerHeaderView = UIView()
        answerHeaderView.preservesSuperviewLayoutMargins = true
        answerHeaderView.backgroundColor = .app_background

        questionTextView = NoSpeakTextView(style: .conversationQuestionMessage)
        questionTextView.backgroundColor = .app_background

        answerTextView = NoSpeakTextView(style: .conversationAnswerMessage)
        answerTextView.backgroundColor = .app_background
        answerTextView.setContentCompressionResistancePriority(.defaultLow + 1, for: .vertical)
        answerTextView.setContentHuggingPriority(.defaultHigh - 1, for: .vertical)

        let stackView = UIStackView(arrangedSubviews: [
            questionTextView,
            answerTextView
        ])
        stackView.axis = .vertical
        stackView.spacing = 9

        answerHeaderView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) -> Void in
            make.leadingMargin.trailingMargin.equalToSuperview()
            make.top.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }

        tableView.tableHeaderView = answerHeaderView

        returnToSearchFooterView = UIView()
        returnToSearchFooterView.preservesSuperviewLayoutMargins = true
        returnToSearchFooterView.backgroundColor = .app_background

        let returnToSearchFooterSeparatorView = SeparatorView()
        returnToSearchFooterSeparatorView.backgroundColor = .app_separator
        returnToSearchFooterLabel = UILabel(style: .articlePageFooter)
        returnToSearchFooterLabel.numberOfLines = 0

        let returnToSearchFooterStackView = UIStackView(arrangedSubviews: [
            returnToSearchFooterSeparatorView,
            returnToSearchFooterLabel
        ])
        returnToSearchFooterStackView.axis = .vertical
        returnToSearchFooterStackView.spacing = 9

        returnToSearchFooterView.addSubview(returnToSearchFooterStackView)
        returnToSearchFooterStackView.snp.makeConstraints { (make) -> Void in
            make.leadingMargin.trailingMargin.equalToSuperview()
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }

        tableView.tableFooterView = returnToSearchFooterView

        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }

        speekingButton = UIBarButtonItem()
        bookmarkButton = UIBarButtonItem()

        navigationItem.rightBarButtonItems = [speekingButton, bookmarkButton]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
        tableView.sizeTableFooterToFit()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard UIApplication.shared.applicationState != .background else { return }
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)
                || traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory else {
            return }
        styleChanged.onNext(Void())
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopPlaying()
    }

    override func viewDidFinish(_ animated: Bool) {
        super.viewDidFinish(animated)
        viewModel.stopPlaying()
    }

    // MARK: - Binding

    final override func setupBindings() {
        Observable.just(viewModel.title)
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        Observable.just(viewModel.returnToSearchCaption)
            .bind(to: returnToSearchFooterLabel.rx.text)
            .disposed(by: disposeBag)

        Observable.just(viewModel.questionText)
            .bind(to: questionTextView.rx.text)
            .disposed(by: disposeBag)

        Observable
            .merge(
                Observable.just(viewModel.answerHtmlBody),
                styleChanged.map { [unowned self] in viewModel.answerHtmlBody })
            .map { Self.generateStyledHtmlAttributedString(for: $0) }
            .bind(to: answerTextView.rx.attributedText)
            .disposed(by: disposeBag)

        speekingButton.rx.action = viewModel.toggleSpeaking

        viewModel.isSpeaking
            .map { ViewStyle<UIBarButtonItem>.toggleSpeaking(isSpeaking: $0) }
            .bind(to: speekingButton.rx.style)
            .disposed(by: disposeBag)

        bookmarkButton.rx.action = viewModel.toggleBookmark

        viewModel.isBookmarked
            .map { ViewStyle<UIBarButtonItem>.bookmark(isFilled: $0) }
            .bind(to: bookmarkButton.rx.style)
            .disposed(by: disposeBag)
    }

    // MARK: - Private

    private static func generateStyledHtmlAttributedString(for htmlBody: String) -> NSAttributedString {
        let scaledFont = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 14))
        return htmlBody.styledHtmlAttributed(fontSize: CGFloat(scaledFont.pointSize), color: .app_labelPrimary)
    }
}
