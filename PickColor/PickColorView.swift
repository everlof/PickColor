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

import Foundation

public protocol PickColorViewDelegate: class {
    func pickColorView(_: PickColorView, didTapSelectedColor: UIColor)
    func pickColorView(_: PickColorView, didPickRecentColor: UIColor)
    func pickColorView(_: PickColorView, didManuallyEnterColor: UIColor)
}

public class PickColorView: UIView, ToolbarViewDelegate {

    public weak var delegate: PickColorViewDelegate?

    public let colorMapControl: ColorMapControl

    public let toolbarControl: ToolbarView

    public var selectedColor: UIColor {
        get {
            return toolbarControl.selectedColor
        }
        set {
            toolbarControl.selectedColor = newValue
            colorMapControl.color = newValue
        }
    }

    public init(initialColor color: UIColor) {
        colorMapControl = ColorMapControl(color: color)
        colorMapControl.translatesAutoresizingMaskIntoConstraints = false

        toolbarControl = ToolbarView(selectedColor: color)
        toolbarControl.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)
        backgroundColor = .clear

        addSubview(toolbarControl)
        addSubview(colorMapControl)

        toolbarControl.topAnchor.constraint(equalTo: topAnchor).isActive = true
        toolbarControl.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        toolbarControl.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        colorMapControl.topAnchor.constraint(equalTo: toolbarControl.bottomAnchor).isActive = true

        colorMapControl.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        colorMapControl.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        colorMapControl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        colorMapControl.addTarget(self, action: #selector(colorMapChangedColor), for: .valueChanged)
        toolbarControl.delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func colorMapChangedColor() {
        toolbarControl.selectedColor = colorMapControl.color
        self.toolbarView(toolbarControl, didPick: toolbarControl.selectedColor)
    }

    // MARK: - ToolbarViewDelegate

    public func toolbarView(_: ToolbarView, didPick color: UIColor) {
        delegate?.pickColorView(self, didTapSelectedColor: color)
    }

    public func toolbarView(_ toolbarView: ToolbarView, didUpdateHue hue: CGFloat) {
        colorMapControl.hue = hue
        self.toolbarView(toolbarControl, didPick: toolbarControl.selectedColor)
    }

    public func toolbarView(_ toolbarView: ToolbarView, didSelectRecentColor color: UIColor) {
        colorMapControl.color = color
        delegate?.pickColorView(self, didPickRecentColor: color)
    }

    public func toolbarView(_ toolbarView: ToolbarView, didManuallyEnterColor color: UIColor) {
        colorMapControl.color = color
        delegate?.pickColorView(self, didManuallyEnterColor: color)
    }

}
