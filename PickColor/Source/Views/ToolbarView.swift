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

public protocol ToolbarViewDelegate: class {
    func toolbarView(_: ToolbarView, didUpdateHue hue: CGFloat)
    func toolbarView(_: ToolbarView, didSelectRecentColor color: UIColor)
    func toolbarView(_: ToolbarView, didManuallyEnterColor color: UIColor)
    func toolbarView(_: ToolbarView, didPick color: UIColor)
}

public class ToolbarView: UIView,
    RecentColorsCollectionViewDelegate,
    ColorTextFieldDelegate,
    CurrentColorViewDelegate {

    public var showCurrentColor: Bool = false

    public var showRecentColors: Bool = false

    public weak var delegate: ToolbarViewDelegate?

    public let currentColorView: CurrentColorView

    public let recentColorsCollectionView = RecentColorsCollectionView()

    public let colorNameLabel = UILabel()

    public let hueSlider: HueSliderControl

    public var hexFont: UIFont? {
        get { return currentColorView.colorHexTextField.font }
        set { currentColorView.colorHexTextField.font = hexFont }
    }

    public var selectedColor: UIColor {
        get {
            return hsv.uiColor
        }
        set {
            hsv = HSVColor(uiColor: newValue)
        }
    }

    private var hsv: HSVColor {
        didSet {
            if oldValue != hsv {
                currentColorView.color = hsv.uiColor
            }
        }
    }

    public init(selectedColor: UIColor) {
        self.currentColorView = CurrentColorView(color: selectedColor)
        hsv = HSVColor(uiColor: selectedColor)
        currentColorView.color = selectedColor
        hueSlider = HueSliderControl(color: selectedColor)
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        hueSlider.translatesAutoresizingMaskIntoConstraints = false
        recentColorsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        if showCurrentColor {
            addSubview(currentColorView)
        }

        if showRecentColors {
            addSubview(recentColorsCollectionView)
        }

        addSubview(hueSlider)
        addSubview(colorNameLabel)

        if showCurrentColor {
            currentColorView.delegate = self
            currentColorView.colorHexTextField.colorTextFieldDelegate = self
        }

        recentColorsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        recentColorsCollectionView.recentColorDelegate = self

        if showCurrentColor {
            currentColorView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
            currentColorView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
            currentColorView.rightAnchor.constraint(equalTo: recentColorsCollectionView.leftAnchor).isActive = true
        } else if showRecentColors {
            recentColorsCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
        }

        if showRecentColors {
            recentColorsCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
            recentColorsCollectionView.heightAnchor.constraint(equalToConstant: 44).isActive = true
            recentColorsCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }

        if showCurrentColor {
            currentColorView.bottomAnchor.constraint(equalTo: hueSlider.topAnchor, constant: -20).isActive = true
            recentColorsCollectionView.bottomAnchor.constraint(equalTo: hueSlider.topAnchor, constant: -20).isActive = true
        } else if showRecentColors {
            recentColorsCollectionView.bottomAnchor.constraint(equalTo: hueSlider.topAnchor).isActive = true
        } else {
            hueSlider.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        }

        hueSlider.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        hueSlider.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        hueSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true

        hueSlider.addTarget(self, action: #selector(hueChanged), for: .valueChanged)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func hueChanged() {
        hsv.h = hueSlider.hue
        delegate?.toolbarView(self, didUpdateHue: hueSlider.hue)
    }

    // MARK: - RecentColorsCollectionViewDelegate

    public func didSelectRecent(color: UIColor) {
        hsv = HSVColor(uiColor: color)
        delegate?.toolbarView(self, didSelectRecentColor: color)
    }

    // MARK: - ColorTextFieldDelegate

    public func didInput(color: UIColor) {
        hsv = HSVColor(uiColor: color)
        delegate?.toolbarView(self, didManuallyEnterColor: color)
    }

    // MARK: - CurrentColorViewDelegate

    public func currentColorView(_: CurrentColorView, didSelectColor color: UIColor) {
        delegate?.toolbarView(self, didPick: color)
    }

}
