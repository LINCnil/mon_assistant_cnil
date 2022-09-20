import Foundation
import UIKit
import RxSwift
import RxCocoa
import Action
import SFSafeSymbols

class PipelineLogsViewController: BaseViewController<PipelineLogsViewModel> {
    private var tableView: UITableView!
    private var shareButton: UIBarButtonItem!
    private var clearButton: UIBarButtonItem!
    private let tableViewDelegateHolder = EstimatedHeightHelperTableViewDelegate()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.reload.execute()
    }

    override func loadView() {
        super.loadView()

        view.backgroundColor = .app_background

        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 300

        tableView.register(PipelineLogTableCell.nib, forCellReuseIdentifier: "PipelineLogTableCell")

        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) -> Void in
            make.top.leading.trailing.bottom.equalToSuperview()
        }

        shareButton = UIBarButtonItem(style: .share)
        clearButton = UIBarButtonItem(style: .trash)
        navigationItem.rightBarButtonItems = [shareButton, clearButton]
    }

    // MARK: - Binding

    final override func setupBindings() {
        viewModel.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        tableView
            .rx.setDelegate(tableViewDelegateHolder)
            .disposed(by: disposeBag)

        viewModel.messages.bind(to: tableView.rx.items(cellIdentifier: "PipelineLogTableCell")) { _, model, cell in
            let assistantCell = cell as! PipelineLogTableCell
            assistantCell.layer.shouldRasterize = true
            assistantCell.layer.rasterizationScale = UIScreen.main.scale
            assistantCell.configure(viewModel: model)
        }
        .disposed(by: disposeBag)

        clearButton.rx.action = viewModel.clean
        shareButton.rx.action = viewModel.share
    }
}
