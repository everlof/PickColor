import UIKit

protocol ColorTextFieldDelegate: class {
    func didInput(color: UIColor)
}

class ColorTextField: UITextField, UITextFieldDelegate {

    weak var colorTextFieldDelegate: ColorTextFieldDelegate?

    // For when entering something that is NOT a HEX-Color.
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    // If canceling editing when a non-valid HEX-Color is present in the textfield,
    // we'll revert to this value.
    private var prevText: String?

    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: superSize.width, height: superSize.height + 18)
    }

    init() {
        super.init(frame: .zero)
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = text, let color = UIColor(hexString: text) {
            colorTextFieldDelegate?.didInput(color: color)
        } else {
            feedbackGenerator.prepare()
            text = prevText
            feedbackGenerator.impactOccurred()

            backgroundColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = .white
            }
        }
        resignFirstResponder()
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        prevText = text
    }

}
