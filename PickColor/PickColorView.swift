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
import UIKit

public class PickColorView: UIControl {

    private let colorMapControl: ColorMapControl

    private let hueSlider: HueSliderControl

    private var lastColor: UIColor? {
        didSet {
            if lastColor != oldValue {
                sendActions(for: .valueChanged)
            }
        }
    }

    public var color: UIColor {
        get {
            return HSVColor(h: hueSlider.hue,
                            s: colorMapControl.saturation,
                            v: colorMapControl.value).uiColor
        }
        set {
            let new = HSVColor(uiColor: newValue)
            hueSlider.set(hue: new.h)
            colorMapControl.set(saturation: new.s, andValue: new.v)
            colorMapControl.set(hue: new.h)
        }
    }

    public init(initialColor color: UIColor) {
        colorMapControl = ColorMapControl(color: color)
        colorMapControl.translatesAutoresizingMaskIntoConstraints = false

        hueSlider = HueSliderControl(color: color)
        hueSlider.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)
        backgroundColor = .clear

        addSubview(hueSlider)
        addSubview(colorMapControl)

        hueSlider.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        hueSlider.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        hueSlider.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        hueSlider.heightAnchor.constraint(equalToConstant: 16).isActive = true

        colorMapControl.topAnchor.constraint(equalTo: hueSlider.bottomAnchor, constant: 24).isActive = true

        colorMapControl.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        colorMapControl.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        colorMapControl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        colorMapControl.addTarget(self, action: #selector(colorMapValueChanged), for: .valueChanged)
        hueSlider.addTarget(self, action: #selector(hueSliderValueChanged), for: .valueChanged)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func colorMapValueChanged() {
        lastColor = color
    }

    @objc private func hueSliderValueChanged() {
        colorMapControl.set(hue: hueSlider.hue)
        lastColor = color
    }

}
