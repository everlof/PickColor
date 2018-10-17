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

public class HueSliderControlMarker: UIView {

    // MARK: - Static configuration

    public static var defaultDiagonal: CGFloat = 28.0

    public static var defaultEditingMagnification: CGFloat = 1.25

    public static var defaultBorderWidth: CGFloat = 5.5

    // MARK:  - Public variables

    public var diagonal = HueSliderControlMarker.defaultDiagonal {
        didSet {
            size = CGSize(width: diagonal, height: diagonal)
        }
    }

    public var borderWidth = HueSliderControlMarker.defaultBorderWidth {
        didSet {
            update(animated: true)
        }
    }

    public var editingMagnification: CGFloat = HueSliderControlMarker.defaultEditingMagnification {
        didSet {
            update(animated: true)
        }
    }

    public var circleBoarderColor = UIColor(white: 0.65, alpha: 1.0) {
        didSet {
            backLayer.borderColor = circleBoarderColor.cgColor
        }
    }

    public var circleColor = UIColor(white: 1.0, alpha: 0.7) {
        didSet {
            backLayer.backgroundColor = circleColor.cgColor
        }
    }

    public var editing: Bool = false {
        didSet {
            update(animated: true)
        }
    }

    public var color: UIColor {
        didSet {
            update(animated: true)
        }
    }

    // MARK: - Private variables

    private var size = CGSize(width: HueSliderControlMarker.defaultDiagonal, height: HueSliderControlMarker.defaultDiagonal) {
        didSet {
            update(animated: true)
        }
    }

    private let backLayer = CALayer()

    private let colorLayer = CALayer()

    public init(color: UIColor) {
        self.color = color
        super.init(frame: CGRect(origin: .zero, size: size))
        backgroundColor = .clear
        isUserInteractionEnabled = false

        let backFrame = CGRect(origin: .zero, size: self.frame.size)
        backLayer.frame = backFrame
        backLayer.cornerRadius = frame.height / 2.0
        backLayer.borderColor = circleBoarderColor.cgColor
        backLayer.backgroundColor = circleColor.cgColor

        layer.addSublayer(backLayer)
        layer.addSublayer(colorLayer)
        update(animated: false)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func update(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0.0 ) {
            self.colorLayer.backgroundColor = self.color.cgColor
            let backFrame = CGRect(origin: .zero, size: self.bounds.size)

            if self.editing {
                // We don't want to change the borders, thus we must adjust their size
                // by dividing it's original size by the magnification we apply

                self.transform = CGAffineTransform.identity.scaledBy(x: self.editingMagnification, y: self.editingMagnification)
                self.colorLayer.frame = backFrame.insetBy(dx: self.borderWidth / self.editingMagnification, dy: self.borderWidth / self.editingMagnification)
                self.backLayer.borderWidth = (1 / UIScreen.main.scale) / self.editingMagnification
            } else {
                self.transform = CGAffineTransform.identity
                self.colorLayer.frame = backFrame.insetBy(dx: self.borderWidth, dy: self.borderWidth)
                self.backLayer.borderWidth = 1 / UIScreen.main.scale
            }

            self.colorLayer.cornerRadius = self.colorLayer.frame.height / 2.0
        }
    }

}
