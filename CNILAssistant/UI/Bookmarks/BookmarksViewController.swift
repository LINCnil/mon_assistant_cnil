

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class BookmarksViewController: BaseViewController<BookmarksViewModel> {
    private var tableView: UITableView!
    private let tableViewDelegateHolder = EstimatedHeightHelperTableViewDelegate()
    private var clearBookmarks: UIBarButtonItem!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(AnswerTableCell.nib, forCellReuseIdentifier: "AnswerTableCell")
    }

    override func loadView() {
        super.loadView()

        view.backgroundColor = .app_background

        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.separatorColor = .app_separator
        tableView.backgroundColor = .app_background
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = 100

        tableView.tableFooterView = UIView()

        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }

        clearBookmarks = UIBarButtonItem(style: .trash)
        navigationItem.rightBarButtonItem = clearBookmarks
    }

    // MARK: - Binding

    final override func setupBindings() {
        Observable.just(viewModel.title)
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        let isEmptyPlaceholderShown = tableView.rx.emptyPlaceholder(
            emptyBacgroundView: createNoItemsView(),
            defaultBackgroundView: tableView.backgroundView,
            defaultSeparatorStyle: tableView.separatorStyle)
        viewModel.items
            .map { $0.first?.items.isEmpty ?? true }
            .distinctUntilChanged()
            .bind(to: isEmptyPlaceholderShown)
            .disposed(by: disposeBag)

        clearBookmarks.rx.action = viewModel.clearBookmarks

        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ConversationTableSectionModel<AnswerEntryViewModel>.Item.self))
            .bind { [unowned self] indexPath, model in
                viewModel.selectAnswer(model.viewModel.answer)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)

        tableView
            .rx.setDelegate(tableViewDelegateHolder)
            .disposed(by: disposeBag)

        viewModel.items
            .bind(to: tableView.rx.items(dataSource: Self.dataSource()))
            .disposed(by: disposeBag)
    }

    // MARK: - Private

    private func createNoItemsView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        view.backgroundColor = .clear

        let titleLabel = UILabel(style: .tableEmptyPlaceholderTitle)
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.text = L10n.Localizable.bookmarksNoItemsTitle
        titleLabel.numberOfLines = 1

        let detailsLabel = UILabel(style: .tableEmptyPlaceholderDetails)
        detailsLabel.backgroundColor = .clear
        detailsLabel.textAlignment = .center
        detailsLabel.setContentCompressionResistancePriority(.defaultLow + 1, for: .vertical)
        detailsLabel.setContentHuggingPriority(.defaultHigh - 1, for: .vertical)
        detailsLabel.text = L10n.Localizable.bookmarksNoItemsMessage
        detailsLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            detailsLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 16

        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) -> Void in
            make.leading.trailing.equalToSuperview().inset(32).priority(.high)
            make.centerY.equalToSuperview()
        }

        return view
    }
}

extension BookmarksViewController {
    static func dataSource() -> RxTableViewSectionedAnimatedDataSource<ConversationTableSectionModel<AnswerEntryViewModel>> {
        return RxTableViewSectionedAnimatedDataSource<ConversationTableSectionModel<AnswerEntryViewModel>>(
            decideViewTransition: { _, _, _ -> ViewTransition in
                return .reload
            },
            configureCell: { (_, tv, indexPath, element) in
                let answerCell = tv.dequeueReusableCell(withIdentifier: "AnswerTableCell", for: indexPath) as! AnswerTableCell
                answerCell.configure(viewModel: element.viewModel)
                return answerCell
            })
    }
}
