import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class SettingsViewController: BaseViewController<SettingsViewModel> {
    private var tableView: UITableView!

    private let disposeBag = DisposeBag()

    private let tableViewDelegateHolder = TableViewDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TitleTableViewCell.nib, forCellReuseIdentifier: "TitleTableViewCell")
        tableView.register(TitleDetailsTableViewCell.nib, forCellReuseIdentifier: "TitleDetailsTableViewCell")
        tableView.register(TitleRightDetailsTableViewCell.nib, forCellReuseIdentifier: "TitleRightDetailsTableViewCell")
        tableView.register(TitleSwitchTableViewCell.nib, forCellReuseIdentifier: "TitleSwitchTableViewCell")
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

    // MARK: - Binding

    final override func setupBindings() {
        viewModel.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        let dataSource = Self.dataSource()

        viewModel.settings
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView
            .rx.setDelegate(tableViewDelegateHolder)
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .bind { [unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(SelectableSettingItem.self)
            .bind { model in
                model.select()
            }
            .disposed(by: disposeBag)
    }
}

private class TableViewDelegate: NSObject, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let settingItem: SettingItem? = try? tableView.rx.model(at: indexPath)
        if let selectableSettingItem = settingItem as? SelectableSettingItem {
            return selectableSettingItem.canSelect ? indexPath : nil
        }
        return nil
    }
}

extension SettingsViewController {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<SettingsTableSectionModel> {
        return RxTableViewSectionedReloadDataSource<SettingsTableSectionModel>(
            configureCell: { dataSource, table, indexPath, _ in
                if let itemModel = dataSource[indexPath] as? TitleSettingItem {
                    let cell = table.dequeueReusableCell(withIdentifier: "TitleTableViewCell") as! TitleTableViewCell
                    cell.configure(viewModel: itemModel)
                    return cell
                } else if let itemModel = dataSource[indexPath] as? InfoSettingItem {
                    let cell = table.dequeueReusableCell(withIdentifier: "TitleDetailsTableViewCell") as! TitleDetailsTableViewCell
                    cell.configure(viewModel: itemModel)
                    return cell
                } else if let itemModel = dataSource[indexPath] as? TitleDetailsSettingItem {
                    let cell = table.dequeueReusableCell(withIdentifier: "TitleRightDetailsTableViewCell") as! TitleRightDetailsTableViewCell
                    cell.configure(viewModel: itemModel)
                    return cell
                } else if let itemModel = dataSource[indexPath] as? BoolSettingItem {
                    let cell = table.dequeueReusableCell(withIdentifier: "TitleSwitchTableViewCell") as! TitleSwitchTableViewCell
                    cell.configure(viewModel: itemModel)
                    return cell
                }
                fatalError("Unknown item model")
            },
            titleForHeaderInSection: { dataSource, index in
                let section = dataSource[index]
                return section.title
            }
        )
    }
}
