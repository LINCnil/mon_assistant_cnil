import Foundation
import UIKit
import RxCocoa
import RxSwift

class FirstLaunchWelcomeViewController: BaseViewController<FirstLaunchWelcomeViewModel> {
    private var startButton: UIButton!
    private var skipButton: UIButton!
    private var welcomeLabel: UILabel!
    private var welcomeTextLabel: UILabel!

    private let disposeBag = DisposeBag()

    override func loadView() {
        super.loadView()

        view.backgroundColor = .app_background

        let logoImageView = UIImageView(image: UIImage(named: "Logo"))

        startButton = UIButton(style: .fillButton)
        startButton.layer.masksToBounds = true

        skipButton = UIButton(style: .tintedButton)
        skipButton.layer.masksToBounds = true

        skipButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(32)
            make.width.equalTo(200)
        }

        startButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(32)
            make.width.equalTo(200)
        }

        let buttonsStackView = UIStackView(arrangedSubviews: [
            startButton,
            skipButton
        ])
        buttonsStackView.alignment = .center
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 16

        welcomeLabel = UILabel(style: .welcomeHeader)
        welcomeLabel.textAlignment = .center

        welcomeTextLabel = UILabel(style: .details)
        welcomeTextLabel.textAlignment = .center
        welcomeTextLabel.numberOfLines = 0

        let labelsStackView = UIStackView(arrangedSubviews: [
            welcomeLabel,
            welcomeTextLabel
        ])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 24

        let mainStackView = UIStackView(arrangedSubviews: [
            labelsStackView,
            buttonsStackView
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 48

        view.addSubview(logoImageView)
        view.addSubview(mainStackView)

        logoImageView.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }

        mainStackView.snp.makeConstraints { (make) -> Void in
            make.width.lessThanOrEqualTo(300)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32).priority(.high)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(40)
        }
    }

    // MARK: - Binding

    final override func setupBindings() {
        Observable.just(viewModel.welcomeTitle)
            .bind(to: welcomeLabel.rx.text)
            .disposed(by: disposeBag)

        Observable.just(viewModel.welcomeText)
            .bind(to: welcomeTextLabel.rx.text)
            .disposed(by: disposeBag)

        Observable.just(viewModel.startButtonTitle)
            .bind(to: startButton.rx.title())
            .disposed(by: disposeBag)

        Observable.just(viewModel.skipButtonTitle)
            .bind(to: skipButton.rx.title())
            .disposed(by: disposeBag)

        skipButton.rx.action = viewModel.skip
        startButton.rx.action = viewModel.start
    }
}
