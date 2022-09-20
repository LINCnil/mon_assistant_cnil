import UIKit
import ProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var applicationCoordinator: ApplicationCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        guard NSClassFromString("XCTestCase") == nil else { return true }
        #endif
        setupAppearance()

        let window = UIWindow(frame: UIScreen.main.bounds)

        applicationCoordinator = ApplicationCoordinator(window: window)
        applicationCoordinator.start()

        return true
    }

    static var current: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    fileprivate let transitionGroup = DispatchGroup()

    public func setRootViewController(
        _ viewController: UIViewController,
        to window: UIWindow,
        animated: Bool = true,
        duration: TimeInterval = 0.35,
        options: UIView.AnimationOptions = [.transitionCrossDissolve, .curveEaseInOut],
        completion: (() -> Void)? = nil) {

        guard animated else {
            window.rootViewController = viewController
            completion?()
            return
        }

        DispatchQueue.global().async {
            self.transitionGroup.enter()

            DispatchQueue.main.async {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                UIView.transition(with: window, duration: duration, options: options, animations: {
                    window.rootViewController = viewController
                }, completion: { _ in
                    UIView.setAnimationsEnabled(oldState)
                    self.transitionGroup.leave()
                    completion?()
                })
            }
        }
    }

    private func setupAppearance() {
        UIWindow.appearance().tintColor = .app_tint

        UIButton.appearance().tintColor = .app_tint
        UISwitch.appearance().onTintColor = .app_tint
        UITableView.appearance().tintColor = .app_tint

        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.isTranslucent = true
        navigationBarAppearance.tintColor = .app_tint
        navigationBarAppearance.barTintColor = .app_background
        navigationBarAppearance
            .titleTextAttributes = [
                .foregroundColor: UIColor.app_labelPrimary
            ]

        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = .app_tint
        ProgressHUD.colorHUD = .app_background
        ProgressHUD.colorStatus = .app_labelPrimary
        ProgressHUD.colorBackground = UIColor.black.withAlphaComponent(0.4)
        ProgressHUD.fontStatus = UIFontMetrics.default.scaledFont(for: .app_font(ofSize: 20))
    }
}
