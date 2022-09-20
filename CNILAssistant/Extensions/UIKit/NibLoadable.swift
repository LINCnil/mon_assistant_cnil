

import UIKit

protocol NibLoadable {}

extension UIView: NibLoadable {}

extension NibLoadable {
    static func fromNib(_ nibNameOrNil: String? = nil,
                        owner: AnyObject? = nil,
                        bundle: Bundle = Bundle.main) -> Self {
        let view: Self? = fromNib(nibNameOrNil, owner: owner, bundle: bundle)
        return view!
    }

    // MARK: - Private

    private static func fromNib(_ nibNameOrNil: String? = nil,
                                owner: AnyObject? = nil,
                                bundle: Bundle = Bundle.main) -> Self? {
        var view: Self?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = "\(Self.self)".components(separatedBy: ".").last!
        }
        guard let nibViews = bundle.loadNibNamed(name, owner: owner, options: nil) else { return nil }
        for nibView in nibViews {
            if let tog = nibView as? Self {
                view = tog
            }
        }
        return view
    }
}
