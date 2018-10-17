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

public protocol CurrentColorViewDelegate: class {
    func currentColorView(_ : CurrentColorView, didSelectColor: UIColor)
}

public class CurrentColorView: UIView {

    public var color: UIColor {
        didSet {
            backgroundView.backgroundColor = color
            colorHexTextField.text = color.hex
        }
    }

    public weak var delegate: CurrentColorViewDelegate?

    private var feedbackGenerator = UISelectionFeedbackGenerator()

    private let containerView = UIStackView()

    internal let colorHexTextField = ColorTextField()

    internal let backgroundView = UIView()

    internal let tapGestureRecognizer = UITapGestureRecognizer()

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 80, height: 100)
    }

    public init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        containerView.axis = .vertical
        translatesAutoresizingMaskIntoConstraints = false

        layer.masksToBounds = true
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        layer.cornerRadius = 3.0

        backgroundColor = .white
        colorHexTextField.textAlignment = .center

        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(didTap))

        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        containerView.addArrangedSubview(backgroundView)
        containerView.addArrangedSubview(colorHexTextField)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTap() {
        feedbackGenerator.prepare()
        delegate?.currentColorView(self, didSelectColor: color)
        feedbackGenerator.selectionChanged()
    }

}
