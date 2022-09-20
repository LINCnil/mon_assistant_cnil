import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RxDataSources

class ConversationViewController: BaseViewController<ConversationViewModel> {
    private var micButton: UIButton!
    private var listeningButton: UIButton!
    private var processingButton: UIButton!

    private var settingsButton: UIBarButtonItem!
    private var bookmarksButton: UIButton!

    private var toggleKeyboardButton: UIButton!
    private var toggleKeyboardButtonShadowView: UIView!
    private var toggleKeyboardButtonAdjustment: CGFloat = 0.0

    private var tableView: UITableView!
    private let tableViewDelegateHolder = EstimatedHeightHelperTableViewDelegate()
    private var inputTextView: ConversationInputToolbarView!
    private var controlBar: UIView!

    private let updatingProgress = ProgressHUDRxWrapper()

    private var toggleKeyboardConstraintToControlBar: Constraint!
    private var toggleKeyboardButtonConstraintToInputView: Constraint!
    private var inputViewConstraintToSuperview: Constraint!

    private let disposeBag = DisposeBag()
    private let defaultTableViewContentInsets = UIEdgeInsets.zero // UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "LogoSmall")
        imageView.image = image
        navigationItem.titleView = imageView

        toggleKeyboardButton.addTarget(self, action: #selector(toggleKeyboard), for: .touchUpInside)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIWindow.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIWindow.keyboardWillHideNotification,
            object: nil
        )

        tableView.register(AnswerTableCell.nib, forCellReuseIdentifier: "AnswerTableCell")
        tableView.register(NoResultTableCell.nib, forCellReuseIdentifier: "NoResultTableCell")
        tableView.register(WelcomeTableCell.nib, forCellReuseIdentifier: "WelcomeTableCell")

        viewModel.initAudioSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        viewModel.stopCaptureVoice()
        viewModel.stopPlaying()
    }

    override func viewDidFinish(_ animated: Bool) {
        super.viewDidFinish(animated)
        viewModel.releaseAudioSession()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func loadView() {
        super.loadView()

        view.backgroundColor = .app_secondaryBackground

        settingsButton = UIBarButtonItem(style: .settings)
        navigationItem.leftBarButtonItem = settingsButton

        bookmarksButton = UIButton(style: .bookmarks)
        bookmarksButton.layer.masksToBounds = true

        micButton = UIButton(style: .microphone)
        micButton.layer.masksToBounds = true

        listeningButton = UIButton(style: .listening)
        listeningButton.layer.masksToBounds = true

        processingButton = UIButton(style: .processing)
        processingButton.isEnabled = false
        processingButton.layer.masksToBounds = true

        let controlsStackView = UIStackView(arrangedSubviews: [micButton, listeningButton, processingButton])
        controlsStackView.axis = .vertical
        controlsStackView.alignment = .center
        controlsStackView.distribution = .fillEqually

        toggleKeyboardButton = UIButton(style: .toggleKeyboard(isKeyboardVisible: false))
        toggleKeyboardButton.layer.masksToBounds = true

        toggleKeyboardButtonShadowView = PassthroughView()
        toggleKeyboardButtonShadowView.backgroundColor = .app_background
        toggleKeyboardButtonShadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        toggleKeyboardButtonShadowView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        toggleKeyboardButtonShadowView.layer.shadowRadius = 4
        toggleKeyboardButtonShadowView.layer.shadowOpacity = 1.0
        toggleKeyboardButtonShadowView.layer.masksToBounds = false
        toggleKeyboardButtonShadowView.clipsToBounds = false
        toggleKeyboardButtonShadowView.isHidden = true

        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.separatorColor = .app_separator
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .none
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = 100
        updateTableViewContentInsets(useDefault: true)

        tableView.tableFooterView = UIView()

        inputTextView = ConversationInputToolbarView.fromNib()
        inputTextView.backgroundColor = .app_background

        controlBar = UIView()
        controlBar.backgroundColor = .app_background

        let contentView = UIView()
        contentView.backgroundColor = .clear

        let topBorderView = SeparatorView()
        topBorderView.backgroundColor = UIColor.app_separator

        controlBar.addSubview(topBorderView)
        controlBar.addSubview(contentView)

        contentView.addSubview(bookmarksButton)
        contentView.addSubview(controlsStackView)
        contentView.snp.makeConstraints { (make) -> Void in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(88)
            make.bottom.equalTo(controlBar.safeAreaLayoutGuide.snp.bottom)
        }

        micButton.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(56)
        }
        listeningButton.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(56)
        }
        processingButton.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(56)
        }

        controlsStackView.snp.makeConstraints { (make) -> Void in
            make.centerX.centerY.equalToSuperview()
        }

        topBorderView.snp.makeConstraints { (make) -> Void in
            make.leading.trailing.top.equalToSuperview()
        }

        view.addSubview(tableView)
        view.addSubview(inputTextView)
        view.addSubview(controlBar)
        view.addSubview(toggleKeyboardButtonShadowView)
        view.addSubview(toggleKeyboardButton)

        controlBar.snp.makeConstraints { (make) -> Void in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom)
        }

        toggleKeyboardButton.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(56)
            make.trailing.equalTo(self.view.snp.trailingMargin).inset(20)

            toggleKeyboardConstraintToControlBar = make.centerY.equalTo(controlsStackView).constraint
            toggleKeyboardButtonConstraintToInputView = make.bottom.equalTo(self.view.snp.bottom).inset(16).constraint
        }

        toggleKeyboardButtonShadowView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(toggleKeyboardButton)
        }

        toggleKeyboardConstraintToControlBar.activate()
        toggleKeyboardButtonConstraintToInputView.deactivate()

        bookmarksButton.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(56)
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.view.snp.leadingMargin).inset(20)
        }

        tableView.snp.makeConstraints { (make) -> Void in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.controlBar.snp.top)
        }

        inputTextView.snp.makeConstraints { (make) -> Void in
            make.leading.trailing.equalToSuperview()
            inputViewConstraintToSuperview = make.bottom.equalTo(self.view.snp.bottom).inset(-inputTextView.frame.height).constraint
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayers()
    }

    // MARK: - Binding

    final override func setupBindings() {
        Observable.just(viewModel.title)
            .bind(to: navigationItem.rx.backButtonTitle)
            .disposed(by: disposeBag)

        Observable.just(viewModel.inputViewPlaceholder)
            .bind(to: inputTextView.rx.placeholder)
            .disposed(by: disposeBag)

        inputTextView.message.bind(onNext: { [weak self] text in
            self?.viewModel.performProcessing(text: text)
            self?.inputTextView.resignFirstResponder()
        }).disposed(by: disposeBag)

        inputTextView.rx
            .observe(CGRect.self, #keyPath(UIView.bounds))
            .subscribe(onNext: { [weak self] _ in
                self?.updateToggleKeyboardButtonConstraint()
                if self?.toggleKeyboardButtonConstraintToInputView.isActive == true {
                    self?.updateTableViewContentInsets(useDefault: false)
                }
            }).disposed(by: disposeBag)

        micButton.rx.tap
            .throttle(RxTimeInterval.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                self?.viewModel.startCaptureVoice()
                self?.inputTextView.resignFirstResponder()
            }).disposed(by: disposeBag)

        listeningButton.rx.tap
            .throttle(RxTimeInterval.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                self?.viewModel.stopCaptureVoice()
            }).disposed(by: disposeBag)

        Observable.combineLatest(viewModel.isModelLoaded, viewModel.isRecordingPermissionsGranted)
            .map { $0 && $1}
            .bind(to: micButton.rx.isEnabled)
            .disposed(by: disposeBag)

        tableView
            .rx.setDelegate(tableViewDelegateHolder)
            .disposed(by: disposeBag)

        viewModel.isRecording
            .map { !$0 }
            .bind(to: listeningButton.rx.isHidden)
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.isRecording, viewModel.isProcessing, viewModel.isModelLoaded)
            .map { !$0 && !$1 && $2}
            .bind(to: settingsButton.rx.isEnabled, toggleKeyboardButton.rx.isEnabled, bookmarksButton.rx.isEnabled)
            .disposed(by: disposeBag)

        Observable.combineLatest(
            Observable.just(viewModel.updatingModelTitle),
            Observable.just(viewModel.updatingModelMessage))
            .map { "\($0)\n\n\($1)" }
            .bind(to: updatingProgress.rx.status)
            .disposed(by: disposeBag)

        viewModel.isModelUpdating.bind(to: updatingProgress.rx.isAnimating).disposed(by: disposeBag)

        viewModel.isProcessing
            .map { !$0 }
            .bind(to: processingButton.rx.isHidden)
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.isRecording, viewModel.isProcessing)
            .map { $0 || $1 }
            .bind(to: micButton.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.alert.bind(to: rx.alert).disposed(by: disposeBag)

        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ConversationTableSectionModel<ConversationEntryViewModel>.Item.self))
            .bind { [unowned self] indexPath, model in
                tableView.deselectRow(at: indexPath, animated: true)
                if let answerModel = model.viewModel as? AnswerEntryViewModel {
                    viewModel.selectAnswer(answerModel.answer)
                }
            }
            .disposed(by: disposeBag)

        viewModel.messages
            .bind(to: tableView.rx.items(dataSource: Self.dataSource()))
            .disposed(by: disposeBag)

        settingsButton.rx.action = viewModel.selectSettings
        bookmarksButton.rx.action = viewModel.selectBookmarks
    }

    // MARK: - Private

    @objc private func toggleKeyboard() {
        if inputTextView.isFirstResponder {
            inputTextView.resignFirstResponder()
        } else {
            inputTextView.becomeFirstResponder()
        }
    }

    private func updateLayers() {
        toggleKeyboardButton.layer.cornerRadius = toggleKeyboardButton.bounds.height / 2
        toggleKeyboardButtonShadowView.layer.cornerRadius = toggleKeyboardButton.bounds.height / 2
        listeningButton.layer.cornerRadius = listeningButton.bounds.height / 2
        bookmarksButton.layer.cornerRadius = bookmarksButton.bounds.height / 2
    }

    private func updateToggleKeyboardButtonConstraint() {
        toggleKeyboardButtonConstraintToInputView.update(inset: 16 + inputTextView.frame.height + toggleKeyboardButtonAdjustment)
    }

    private func updateTableViewContentInsets(useDefault: Bool) {
        var contentInset = defaultTableViewContentInsets
        if !useDefault {
            contentInset.bottom = defaultTableViewContentInsets.bottom
                + inputTextView.frame.height
                + toggleKeyboardButtonAdjustment
                - controlBar.frame.height
        }
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }

    // MARK: - Keyboard Events

    @objc private func keyboardWillShow(notification: NSNotification) {
        inputViewConstraintToSuperview.update(inset: notification.keyboardFrameEnd.size.height)
        toggleKeyboardButtonAdjustment = notification.keyboardFrameEnd.height
        toggleKeyboardConstraintToControlBar.deactivate()
        updateToggleKeyboardButtonConstraint()
        toggleKeyboardButtonConstraintToInputView.activate()

        updateTableViewContentInsets(useDefault: false)
        toggleKeyboardButtonShadowView.isHidden = false

        UIView.animate(
            withDuration: notification.keyboardAnimationDuration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: UInt(notification.keyboardAnimationCurve.rawValue)),
            animations: { self.view.layoutIfNeeded() },
            completion: { _ in self.toggleKeyboardButton.applyStyle(.toggleKeyboard(isKeyboardVisible: true)) }
        )
    }

    @objc private func keyboardWillHide(_ notification: NSNotification) {
        inputViewConstraintToSuperview.update(inset: -inputTextView.frame.height)
        toggleKeyboardButtonAdjustment = 0.0
        toggleKeyboardButtonConstraintToInputView.deactivate()
        toggleKeyboardConstraintToControlBar.activate()

        updateTableViewContentInsets(useDefault: true)

        UIView.animate(
            withDuration: notification.keyboardAnimationDuration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: UInt(notification.keyboardAnimationCurve.rawValue)),
            animations: { self.view.layoutIfNeeded() },
            completion: { _ in
                self.toggleKeyboardButtonShadowView.isHidden = true
                self.toggleKeyboardButton.applyStyle(.toggleKeyboard(isKeyboardVisible: false))
            }
        )
    }
}

extension ConversationViewController {
    static func dataSource() -> RxTableViewSectionedAnimatedDataSource<ConversationTableSectionModel<ConversationEntryViewModel>> {
        return RxTableViewSectionedAnimatedDataSource<ConversationTableSectionModel<ConversationEntryViewModel>>(
            decideViewTransition: { _, _, _ -> ViewTransition in
                return .reload
            },
            configureCell: { (_, tv, indexPath, element) in

                var cell: UITableViewCell! = nil

                if let answerModel = element.viewModel as? AnswerEntryViewModel {
                    let answerCell = tv.dequeueReusableCell(withIdentifier: "AnswerTableCell", for: indexPath) as! AnswerTableCell
                    answerCell.configure(viewModel: answerModel)
                    answerCell.layer.shouldRasterize = true
                    answerCell.layer.rasterizationScale = UIScreen.main.scale
                    cell = answerCell
                } else if let noResultsViewModel = element.viewModel as? NoResultEntryViewModel {
                    let noResultsCell = tv.dequeueReusableCell(withIdentifier: "NoResultTableCell", for: indexPath) as! NoResultTableCell
                    noResultsCell.configure(viewModel: noResultsViewModel)
                    cell = noResultsCell
                } else if let welcomeViewModel = element.viewModel as? WelcomeEntryViewModel {
                    let welcomeCell = tv.dequeueReusableCell(withIdentifier: "WelcomeTableCell", for: indexPath) as! WelcomeTableCell
                    welcomeCell.configure(viewModel: welcomeViewModel)
                    cell = welcomeCell
                }

                return cell
            })
    }
}

extension ConversationViewController: RxAlertViewable {}
