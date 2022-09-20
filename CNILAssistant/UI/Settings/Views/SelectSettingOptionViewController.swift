import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxDataSources

 protocol SelectSettingOptionViewControllerDelegate: class {
    func didSelectOption(_ index: Int)
 }

class SelectSettingOptionViewController: UIViewControllerExt {
    private var tableView: UITableView!

    private let disposeBag = DisposeBag()

    var settingTitle: String!
    var selectedSettingOption: Int?
    var settingOptions: [String]!

    var onSelected: ((Int?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SettingOptionTableViewCell.nib, forCellReuseIdentifier: "SettingOptionTableViewCell")
        setupBindings()
    }

    override func loadView() {
        super.loadView()

        view.backgroundColor = .app_secondaryBackground

        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .app_separator
        tableView.backgroundColor = .clear
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = 44

        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedSettingOption = selectedSettingOption {
            tableView.selectRow(at: IndexPath(row: selectedSettingOption, section: 0), animated: false, scrollPosition: .middle)
        }
    }

    // MARK: - Binding

    private func setupBindings() {
        guard let options = self.settingOptions else { fatalError("settingOptions can not be nil") }
        guard let title = self.settingTitle else { fatalError("settingTitle can not be nil") }

        Observable.just(title)
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .bind { [unowned self] indexPath in
                self.onSelected?(indexPath.row)
            }
            .disposed(by: disposeBag)

        Observable.just(options).bind(to: tableView.rx.items(cellIdentifier: "SettingOptionTableViewCell")) { _, model, cell in
            let cell = cell as! SettingOptionTableViewCell
            cell.configure(title: model)
        }
        .disposed(by: disposeBag)
    }
}
