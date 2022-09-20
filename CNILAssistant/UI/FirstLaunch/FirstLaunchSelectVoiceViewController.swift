import Foundation
import UIKit
import RxCocoa
import RxSwift

class FirstLaunchSelectVoiceViewController: BaseViewController<FirstLaunchSelectVoiceViewModel> {
    private var nextButton: UIButton!
    private var backButton: UIButton!
    private var maleButton: UIButton!
    private var femaleButton: UIButton!
    private var titleLabel: UILabel!
    private var textLabel: UILabel!
    private var pageControl: UIPageControl!

    private let disposeBag = DisposeBag()

    override func loadView() {
        super.loadView()

        view.backgroundColor = .app_background

        nextButton = UIButton(style: .fillButton)
        nextButton.layer.masksToBounds = true

        backButton = UIButton(style: .tintedButton)
        backButton.layer.masksToBounds = true

        backButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(32)
            make.width.equalTo(95)
        }

        nextButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(32)
            make.width.equalTo(95)
        }

        titleLabel = UILabel(style: .welcomeHeader)
        titleLabel.textAlignment = .center

        textLabel = UILabel(style: .details)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0

        let labelsStackView = UIStackView(arrangedSubviews: [
            titleLabel,
            textLabel
        ])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 24

        maleButton = UIButton(style: .welcomeOptionButton)
        maleButton.layer.masksToBounds = true

        maleButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(128)
            make.height.equalTo(78)
        }

        femaleButton = UIButton(style: .welcomeOptionButton)
        femaleButton.layer.masksToBounds = true

        femaleButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(128)
            make.height.equalTo(78)
        }

        let optionsStackView = UIStackView(arrangedSubviews: [
            maleButton,
            femaleButton
        ])
        optionsStackView.alignment = .center
        optionsStackView.distribution = .fillEqually
        optionsStackView.axis = .horizontal
        optionsStackView.spacing = 16

        let mainStackView = UIStackView(arrangedSubviews: [
            labelsStackView,
            optionsStackView
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 48

        pageControl = UIPageControl()
        pageControl.isEnabled = false
        pageControl.currentPageIndicatorTintColor = .app_tint
        pageControl.pageIndicatorTintColor = .app_separator

        pageControl.numberOfPages = 2
        pageControl.currentPage = 0

        view.addSubview(mainStackView)
        view.addSubview(pageControl)
        view.addSubview(backButton)
        view.addSubview(nextButton)

        mainStackView.snp.makeConstraints { (make) -> Void in
            make.width.lessThanOrEqualTo(300)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32).priority(.high)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(56)
        }

        pageControl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        backButton.snp.makeConstraints { (make) -> Void in
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
        }

        nextButton.snp.makeConstraints { (make) -> Void in
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        // To apply cgcolor
        maleButton.applyStyle(.welcomeOptionButton)
        femaleButton.applyStyle(.welcomeOptionButton)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustImageAndTitleOffsetsForButton(button: maleButton)
        adjustImageAndTitleOffsetsForButton(button: femaleButton)
    }

    private func adjustImageAndTitleOffsetsForButton(button: UIButton) {
        guard let buttonImageView = button.imageView, let buttonTitleLabel = button.titleLabel else {
            return
        }
        let spacing: CGFloat = 14.0
        let imageSize = buttonImageView.frame.size
        button.titleEdgeInsets = UIEdgeInsets(top: -(imageSize.height + spacing), left: -imageSize.width, bottom: 0, right: 0)
        let titleSize = buttonTitleLabel.frame.size
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -(titleSize.height + spacing), right: -titleSize.width)
    }

    // MARK: - Binding

    final override func setupBindings() {
        Observable.just(viewModel.currentPage)
            .bind(to: pageControl.rx.currentPage)
            .disposed(by: disposeBag)

        Observable.just(viewModel.numberOfPages)
            .bind(to: pageControl.rx.numberOfPages)
            .disposed(by: disposeBag)

        Observable.just(viewModel.title)
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        Observable.just(viewModel.text)
            .bind(to: textLabel.rx.text)
            .disposed(by: disposeBag)

        Observable.just(viewModel.nextButtonTitle)
            .bind(to: nextButton.rx.title())
            .disposed(by: disposeBag)

        Observable.just(viewModel.backButtonTitle)
            .bind(to: backButton.rx.title())
            .disposed(by: disposeBag)

        Observable.just(viewModel.femaleButtonTitle)
            .bind(to: femaleButton.rx.title())
            .disposed(by: disposeBag)

        Observable.just(viewModel.maleButtonTitle)
            .bind(to: maleButton.rx.title())
            .disposed(by: disposeBag)

        maleButton.rx.tap
            .bind(onNext: { [unowned self] in viewModel.select(voice: .male) })
            .disposed(by: disposeBag)

        viewModel.selected
            .map { $0 == .male }
            .bind(to: maleButton.rx.isSelected)
            .disposed(by: disposeBag)

        femaleButton.rx.tap
            .bind(onNext: { [unowned self] in viewModel.select(voice: .female) })
            .disposed(by: disposeBag)

        viewModel.selected
            .map { $0 == .female }
            .bind(to: femaleButton.rx.isSelected)
            .disposed(by: disposeBag)

        nextButton.rx.action = viewModel.next
        backButton.rx.action = viewModel.back
    }
}
