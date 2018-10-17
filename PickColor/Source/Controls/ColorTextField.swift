// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import UIKit

public protocol ColorTextFieldDelegate: class {
    func didInput(color: UIColor)
}

/// Textfield that is used to present hex-values from a colors.
///
/// It can be used to input colors via the keyboard as well.
public class ColorTextField: UITextField, UITextFieldDelegate {

    /// Delegate for listening to when a proper hex-color has been entered into the textfield.
    public weak var colorTextFieldDelegate: ColorTextFieldDelegate?

    public override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: superSize.width, height: superSize.height + 12)
    }

    // For when entering something that is NOT a HEX-Color.
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    // If canceling editing when a non-valid HEX-Color is present in the textfield,
    // we'll revert to this value.
    private var prevText: String?

    public init() {
        super.init(frame: .zero)
        delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else { return false }
        let newText = currentText.replacingCharacters(in: range, with: string)
        return newText.first == "#" ? newText.count <= 7 : newText.count <= 6
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        prevText = text
    }

}
