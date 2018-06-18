import UIKit

protocol ComposerDelegate: class {
    func composerDidBeginEditing(_ composer: Composer)
    func composerDidEndEditing(_ composer: Composer)
    func composerDidSubmit(_ composer: Composer)

    func composerSearchDidBegin(_ composer: Composer)
    func composerSearchDidEnd(_ composer: Composer)
    func composerSearchDidChange(_ composer: Composer)

    func composerPhotoPickerShouldShow(_ composer: Composer)
}

extension ComposerDelegate {
    func composerDidBeginEditing(_ composer: Composer) {}
    func composerDidEndEditing(_ composer: Composer) {}
    func composerDidSubmit(_ composer: Composer) {}

    func composerSearchDidBegin(_ composer: Composer) {}
    func composerSearchDidEnd(_ composer: Composer) {}
    func composerSearchDidChange(_ composer: Composer) {}

    func composerPhotoPickerShouldShow(_ composer: Composer) {}
}

class Composer: UIInputView {

    weak var delegate: ComposerDelegate?

    var insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var bottomSafeAreaInset: CGFloat = 0 {
        didSet { bottomSafeAreaConstraint?.constant = -(bottomSafeAreaInset + insets.bottom) }
    }
    var bottomSafeAreaConstraint: NSLayoutConstraint?

    var text: String? {
        guard isPlaceholding != true else { return nil }
        guard textView.text != "" else { return nil }
        return textView.text
    }

    var query: String? {
        get {
            guard searchIcon.isHidden == false else { return nil }
            guard isPlaceholding == false else { return nil }
            return textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        set {
            if newValue == nil {
                searchModeOff()
            } else {
                searchModeOn()
                placeholderOff(with: newValue!)
            }
        }
    }

    var placeholder = "Message"
    var placeholderColor = UIColor.lightGray

    var isPlaceholding = true
    var isSearching: Bool { return !searchIcon.isHidden }

    let contentView = UIView()
    let textView = UITextView()
    let searchIcon = UIImageView()
    let primaryButton = PrimaryButton()

    var textViewHeightAnchor: NSLayoutConstraint!

    init() {
        super.init(frame: .zero, inputViewStyle: .default)

        autoresizingMask = [.flexibleHeight]
        backgroundColor = .background

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)

        textView.delegate = self
        textView.font = .preferredFont(forTextStyle: .body)
        textView.layer.cornerRadius = 19
        textView.layer.borderColor = UIColor(white: 0.7, alpha: 1).cgColor
        textView.layer.borderWidth = 1 / UIScreen.main.scale
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 28 + 8)
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.keyboardType = .twitter
        textView.backgroundColor = .white
        contentView.addSubview(textView)

        searchIcon.image = .iconSearch
        searchIcon.tintColor = .systemGray
        searchIcon.layer.cornerRadius = 6
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.isHidden = true
        contentView.addSubview(searchIcon)

        primaryButton.stage = .photo
        primaryButton.addTarget(self, action: #selector(handlePrimaryTapped), for: .primaryActionTriggered)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(primaryButton)

        textViewHeightAnchor = textView.heightAnchor.constraint(equalToConstant: 96)

        bottomSafeAreaConstraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            bottomSafeAreaConstraint!,

            searchIcon.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -7),
            searchIcon.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8),
            searchIcon.widthAnchor.constraint(equalToConstant: 24),
            searchIcon.heightAnchor.constraint(equalToConstant: 24),

            primaryButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -5),
            primaryButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -5),
            primaryButton.widthAnchor.constraint(equalToConstant: 28),
            primaryButton.heightAnchor.constraint(equalToConstant: 28),
        ])

        reload()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: max(38, textView.bounds.height) +
            insets.top + insets.bottom)
    }

    func reload() {
        textView.isScrollEnabled = false
        textViewHeightAnchor.isActive = false
        placeholderOn()
    }

    @objc private func handlePrimaryTapped() {
        switch primaryButton.stage {
        case .send:
            delegate?.composerDidSubmit(self)
        case .photo:
            delegate?.composerPhotoPickerShouldShow(self)
        case .clear:
            reload()
            searchModeOff()
        case .none:
            break
        }
    }

    // MARK: - Placeholder

    private func placeholderOff(with value: String = "") {

        // Must be set before setting the text attribute otherwise
        // the cursor won't appear at the end of the text.
        isPlaceholding = false

        textView.text = value
        textView.textColor = .black

        primaryButton.stage = isSearching ? .clear : .send
    }

    private func placeholderOn() {
        textView.text = isSearching ? "Search" : placeholder
        textView.textColor = placeholderColor
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)

        // Must be set after setting the text view text otherwise it
        // will cause an infinite loop with textViewDidChangeSelection().
        isPlaceholding = true

        primaryButton.stage = isSearching ? .clear : .photo
    }

    // MARK: - Search

    private func searchModeOn() {
        guard searchIcon.isHidden else {
            return
        }
        searchIcon.isHidden = false
        var textInsets = textView.textContainerInset
        textInsets.left += 18
        textView.textContainerInset = textInsets
        primaryButton.stage = .clear
        textView.text = "Search"
        delegate?.composerSearchDidBegin(self)
    }

    private func searchModeOff() {
        guard searchIcon.isHidden == false else {
            return
        }
        searchIcon.isHidden = true
        var textInsets = textView.textContainerInset
        textInsets.left -= 18
        textView.textContainerInset = textInsets

        // TODO: Figure out exactly why this is necessary
        searchQueryChanged()

        primaryButton.stage = .photo
        textView.text = placeholder
        delegate?.composerSearchDidEnd(self)
    }

    private func searchQueryChanged() {
        delegate?.composerSearchDidChange(self)
    }
}

extension Composer: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // Show Search Mode when first character is a space character
        if text == " " && range.length == 0 && range.location == 0 { searchModeOn(); return false }

        // Dismiss Search Mode when first character is an empty character
        if text == "" && range.length == 0 && range.location == 0 { searchModeOff(); return false }

        // Determine the new text value
        let oldText = textView.text ?? ""
        let newText = oldText.replacingCharacters(in: Range(range, in: oldText)!, with: text)

        // Return early and replace with placeholder when new text is empty
        guard newText.isEmpty != true else {
            placeholderOn()
            if searchIcon.isHidden == false { searchQueryChanged() }
            return false
        }

        // Prepare text view for a value
        if textView.text == (isSearching ? "Search" : placeholder) && !text.isEmpty {
            placeholderOff(with: "")
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.bounds.height >= textViewHeightAnchor.constant {
            textView.isScrollEnabled = true
            textViewHeightAnchor.isActive = true
        } else {
            textView.isScrollEnabled = false
            textViewHeightAnchor.isActive = false
        }

        // HACK: Ensure text color is correct, color wasn't changing when pasting
        // into the text view. Setting it here ensures it will be the correct color.
        // This could be fixed in later release of iOS, unclear if this is a bug.
        textView.textColor = isPlaceholding ? placeholderColor : .black

        if searchIcon.isHidden == false {
            searchQueryChanged()
            return
        }
    }

    func textViewDidChangeSelection(_ textView: UITextView) {

        // Prevent repositioning of the cursor while displaying placeholder
        guard isPlaceholding else { return }
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return false
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.composerDidBeginEditing(self)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.composerDidEndEditing(self)
    }
}

class PrimaryButton: UIControl {

    enum Stage {
        case send
        case photo
        case clear
        case none
    }

    var stage: Stage = .none { didSet{ stageDidSet() }}

    private let background = CALayer()

    convenience init() {
        self.init(frame: .zero)

        background.frame = bounds
        background.backgroundColor = UIColor.systemRed.cgColor
        layer.addSublayer(background)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapped))
        addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        animateBackground()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let frame = bounds.insetBy(dx: -20, dy: -20)
        return frame.contains(point)
    }

    @objc func handleTapped() {
        sendActions(for: .primaryActionTriggered)
    }

    func stageDidSet() {
        animateBackground()
    }

    func animateBackground() {
        switch stage {
        case .send:
            background.backgroundColor = UIColor.systemRed.cgColor
            background.frame = bounds
            background.contents = UIImage.iconArrowUp.cgImage
        case .photo:
            background.backgroundColor = UIColor.systemGray.cgColor
            background.frame = bounds
            background.contents = UIImage.iconCamera.cgImage
        case .clear:
            background.backgroundColor = UIColor.systemGray.cgColor
            background.frame = bounds.insetBy(dx: 7, dy: 7)
            background.contents = UIImage.iconClear.cgImage
        case .none:
            background.backgroundColor = UIColor.clear.cgColor
            background.frame = bounds
            background.contents = nil
        }
        background.cornerRadius = background.frame.height / 2
    }
}
