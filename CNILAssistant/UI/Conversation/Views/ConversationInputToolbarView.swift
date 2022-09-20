import UIKit
import RxSwift
import RxCocoa

class ConversationInputToolbarView: UIView {
    @IBOutlet fileprivate weak var sendButton: UIButton!
    @IBOutlet fileprivate weak var textView: UITextViewWithPlaceholder!
    @IBOutlet fileprivate weak var textViewHeightConstraint: NSLayoutConstraint!

    private let disposeBag = DisposeBag()

    let message = PublishSubject<String>()

    private override init(frame: CGRect) {
        fatalError("Unavailable")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .app_background
        sendButton.applyStyle(.send)

        sendButton.isEnabled = false

        textView.applyStyle(.input)

        textView.delegate = self

        textView.rx.text.orEmpty
            .map({ !$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty })
            .bind(to: sendButton.rx.isEnabled)
            .disposed(by: disposeBag)

        sendButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.message.onNext(self.text ?? "")
                self.text = nil
                self.updateTextViewHeightConstraint()
            }.disposed(by: disposeBag)

        updateTextViewHeightConstraint()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }

    private func updateLayers() {
        sendButton.layer.cornerRadius = sendButton.bounds.height / 2
    }

    var text: String? {
        get {
            textView.text
        }
        set(value) {
            textView.text = value
        }
    }

    var textColor: UIColor? {
        get {
            textView.textColor
        }
        set(value) {
            textView.textColor = value
        }
    }

    var placeholder: String {
        get {
            textView.placeholder
        }
        set(value) {
            textView.placeholder = value
        }
    }

    var placeholderColor: UIColor? {
        get {
            textView.placeholderColor
        }
        set(value) {
            textView.placeholderColor = value
        }
    }

    var font: UIFont? {
        get {
            textView.font
        }
        set(value) {
            textView.font = value
        }
    }

    var keyboardType: UIKeyboardType {
        get {
            textView.keyboardType
        }
        set(value) {
            textView.keyboardType = value
        }
    }

    var autocorrectionType: UITextAutocorrectionType {
        get {
            textView.autocorrectionType
        }
        set(value) {
            textView.autocorrectionType = value
        }
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            textView.autocapitalizationType
        }
        set(value) {
            textView.autocapitalizationType = value
        }
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        textView.resignFirstResponder()
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }

    override var canResignFirstResponder: Bool {
        textView.canResignFirstResponder
    }

    override var isFirstResponder: Bool {
        textView.isFirstResponder
    }

    override var canBecomeFirstResponder: Bool {
        textView.canBecomeFirstResponder
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory else {
            return }
        textView.applyStyle(.input)
        updateTextViewHeightConstraint()
    }

    private func updateTextViewHeightConstraint() {
        let textViewContentSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.infinity))
        let lineHeight = CGFloat(Int(textView.font?.lineHeight ?? 12) + 1)
        let minimumHeight = lineHeight + textView.textContainerInset.top + textView.textContainerInset.bottom
        let maximumHeight = 3.5 * lineHeight + textView.textContainerInset.top + textView.textContainerInset.bottom

        if textViewContentSize.height > maximumHeight {
            textViewHeightConstraint.constant = maximumHeight
            textView.isScrollEnabled = true
        } else if textViewContentSize.height < minimumHeight {
            textViewHeightConstraint.constant = minimumHeight
            textView.isScrollEnabled = false
        } else {
            textViewHeightConstraint.constant = textViewContentSize.height
            textView.isScrollEnabled = false
        }
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
    }
}

extension ConversationInputToolbarView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 200
    }

    func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeightConstraint()
    }
}
