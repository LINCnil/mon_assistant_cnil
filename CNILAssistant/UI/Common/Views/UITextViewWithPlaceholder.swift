
import UIKit

@IBDesignable
final class UITextViewWithPlaceholder: UITextView {

    private let placeholderTextView: UITextView

    var placeholder: String {
        get {
            placeholderTextView.text
        }
        set {
            placeholderTextView.text = newValue
        }
    }

    var placeholderColor: UIColor? {
        get {
            placeholderTextView.textColor
        }
        set {
            placeholderTextView.textColor = newValue
        }
    }

    override var textContainerInset: UIEdgeInsets {
        didSet {
            placeholderTextView.textContainerInset = textContainerInset
            placeholderTextView.textContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        }
    }

    override var contentInset: UIEdgeInsets {
        didSet {
            placeholderTextView.contentInset = contentInset
        }
    }

    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderTextView.textAlignment = textAlignment
        }
    }

    override var font: UIFont? {
        didSet {
            placeholderTextView.font = font
        }
    }

    override var text: String! {
        didSet {
            updatePlaceholderVisibility()
        }
    }

    required init?(coder: NSCoder) {
        placeholderTextView = UITextView()
        super.init(coder: coder)
        setupPlaceholder()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        placeholderTextView = UITextView()
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        resizePlaceholderFrame()
    }

    override func becomeFirstResponder() -> Bool {
        updatePlaceholderVisibility()
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        updatePlaceholderVisibility()
        return super.resignFirstResponder()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let base = super.sizeThatFits(size)
        let placeholder = placeholderTextView.sizeThatFits(size)
        return base.height > placeholder.height ? base : placeholder
    }

    private func setupPlaceholder() {
        placeholderTextView.isOpaque = false
        placeholderTextView.backgroundColor = .clear
        placeholderTextView.isEditable = false
        placeholderTextView.isSelectable = false
        placeholderTextView.isScrollEnabled = false
        placeholderTextView.isUserInteractionEnabled = false
        placeholderTextView.isAccessibilityElement = false

        placeholderTextView.textAlignment = textAlignment
        placeholderTextView.font = font
        placeholderTextView.contentOffset = contentOffset
        placeholderTextView.contentInset = contentInset

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange(notification:)),
            name: UITextView.textDidChangeNotification,
            object: self
        )

        addSubview(placeholderTextView)
        updatePlaceholderVisibility()
    }

    private func updatePlaceholderVisibility() {
        if let text = text, !text.isEmpty {
            placeholderTextView.isHidden = true
        } else {
            placeholderTextView.isHidden = false
            bringSubviewToFront(placeholderTextView)
        }
    }

    private func resizePlaceholderFrame() {
        placeholderTextView.frame = bounds
    }

    @objc private func textDidChange(notification: NSNotification) {
        updatePlaceholderVisibility()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
