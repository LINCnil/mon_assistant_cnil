
import Foundation
import UIKit
import RxCocoa
import RxSwift

class FirstLaunchSpeechOptionsViewController: BaseViewController<FirstLaunchSpeechOptionsViewModel> {
    private var nextButton: UIButton!
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var textLabel: UILabel!

    private var speechAutostartSwitch: UISwitch!
    private var speechAutostartLabel: UILabel!
    private var speakFullArticleSwitch: UISwitch!
    private var speakFullArticleLabel: UILabel!
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

        speechAutostartSwitch = UISwitch()
        speechAutostartLabel = UILabel(style: .title)

        let speechAutostartStackView = UIStackView(arrangedSubviews: [
            speechAutostartLabel,
            speechAutostartSwitch
        ])
        speechAutostartStackView.axis = .horizontal
        speechAutostartStackView.spacing = 16

        speakFullArticleSwitch = UISwitch()
        speakFullArticleLabel = UILabel(style: .title)

        let speakFullArticleStackView = UIStackView(arrangedSubviews: [
            speakFullArticleLabel,
            speakFullArticleSwitch
        ])
        speakFullArticleStackView.axis = .horizontal
        speakFullArticleStackView.spacing = 16

        let optionsStackView = UIStackView(arrangedSubviews: [
            speechAutostartStackView,
            speakFullArticleStackView
        ])
        optionsStackView.distribution = .fillEqually
        optionsStackView.axis = .vertical
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

        pageControl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        mainStackView.snp.makeConstraints { (make) -> Void in
            make.width.lessThanOrEqualTo(300)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32).priority(.high)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(56)
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

        Observable.just(viewModel.speechAutostartText)
            .bind(to: speechAutostartLabel.rx.text)
            .disposed(by: disposeBag)

        Observable.just(viewModel.speakFullArticleText)
            .bind(to: speakFullArticleLabel.rx.text)
            .disposed(by: disposeBag)

        nextButton.rx.action = viewModel.next
        backButton.rx.action = viewModel.back

        viewModel.isAutospeechOptionOn
            .distinctUntilChanged()
            .bind(to: speechAutostartSwitch.rx.isOn)
            .disposed(by: disposeBag)

        viewModel.isFullArticleOptionOn
            .distinctUntilChanged()
            .bind(to: speakFullArticleSwitch.rx.isOn)
            .disposed(by: disposeBag)

        speechAutostartSwitch.rx
            .controlEvent(.valueChanged)
            .withLatestFrom(speechAutostartSwitch.rx.value)
            .bind(onNext: { [unowned self] in viewModel.changeAutospeechOption(to: $0) })
            .disposed(by: disposeBag)

        speakFullArticleSwitch.rx
            .controlEvent(.valueChanged)
            .withLatestFrom(speakFullArticleSwitch.rx.value)
            .bind(onNext: { [unowned self] in viewModel.changeFullArticleOption(to: $0) })
            .disposed(by: disposeBag)
    }
}
