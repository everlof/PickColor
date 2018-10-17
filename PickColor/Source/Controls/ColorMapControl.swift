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

/// Control for changing that `saturation` and the `value` of that color-picker.
///
/// This control will send `.valueChanged` whenever `saturation` or `value` changed.
///
/// `hue` can be modified by just setting it, however it won't affect `.valueChanged`,
/// it will only change the background color of `ColorMapControl`.
///
/// Setting the `color` will not generate a `.valueChanged` event either.
///
/// `ColorMapControl` is supposed to be used together with `HueSliderControl`.
///
/// If you don't want to use `PickColorView`, but want to use `ColorMapControl` standalone,
/// you can read the code in `PickColorView` to see how it's used from there.
public class ColorMapControl: UIControl {

    // MARK: Static variables

    /// This sets the timing function for "value" for all created `ColorMapControl`s
    /// See members documentation for `valueTimingFunction` for a longer description.
    public static var defaultValueTimingFunction: SKTimingFunction? = SKTimingFunction(controlPoints: 0.6, 0.96, 0.61, 1.0)

    /// This sets the timing function for "saturation" for all created `ColorMapControl`s
    /// See members documentation for `saturationTimingFunction` for a longer description.
    public static var defaultSaturationTimingFunction: SKTimingFunction? = nil

    // MARK: Public variables

    /// This sets the function used to calculate the value of `value` as the
    /// gradient color fades from y=0 to y=frame.height.
    ///
    /// Use http://cubic-bezier.com to play with the control-points to find a good value
    /// if you're not satisfied with the default ones provided by that library.
    public var valueTimingFunction: SKTimingFunction? = ColorMapControl.defaultValueTimingFunction

    /// This sets the function used to calculate the value of `saturation` as the
    /// gradient color fades from x=0 to x=frame.width.
    ///
    /// Use http://cubic-bezier.com to play with the control-points to find a good value
    /// if you're not satisfied with the default ones provided by that library.
    public var saturationTimingFunction: SKTimingFunction? = ColorMapControl.defaultSaturationTimingFunction

    /// The color that is currently selected.
    /// This is evaluated using the current "hue" and the values
    /// of "value" and "saturation" (which depends on the markers position).
    public var color: UIColor {
        get {
            return HSVColor(h: hsv.h, s: hsv.s, v: hsv.v).uiColor
        }
        set {
            marker.center = point(from: newValue, in: frame)
            hsv = HSVColor(uiColor: newValue)
        }
    }

    /// The "hue" of the whole color map, changing this value
    /// will result in the whole map being redrawn with the new hue.
    ///
    /// A value in the range 0 - 1
    public var hue: CGFloat {
        get { return hsv.h }
        set { hsv.h = newValue }
    }

    /// The "saturation" of the color map. This is the saturation
    /// that is currently selected by the marker in the view.
    ///
    /// A value in the range 0 - 1
    public var saturation: CGFloat {
        get { return hsv.s }
        set { hsv.s = newValue }
    }

    /// The "value" of the color map. This is the value
    /// that is currently selected by the marker in the view.
    ///
    /// A value in the range 0 - 1
    public var value: CGFloat {
        get { return hsv.v }
        set { hsv.v = newValue }
    }
    
    // MARK: Private variables

    private var hsv: HSVColor {
        didSet {
            let hueUpdated = oldValue.h != hsv.h
            let saturationAndValueUpdated = oldValue.s != hsv.s || oldValue.v != hsv.v

            if hueUpdated {
                updateColorMap()
                if !saturationAndValueUpdated {
                    // If we only updated Hue (most likely from
                    // the hue slider), we must update the marker
                    // here, because `updateMarker` won't be
                    // called when `saturationAndValueUpdated` is `false`.
                    marker.color = hsv.uiColor
                }
            }

            if saturationAndValueUpdated {
                updateMarker()
                sendActions(for: .valueChanged)
            }
        }
    }

    private let marker: ColorMapControlMarker

    private let feedbackGenerator = UISelectionFeedbackGenerator()

    private var colorMapLayer: CALayer!

    private var colorMapImage: UIImage!

    private let panGestureRecognizer = UIPanGestureRecognizer()

    private let tapGestureRecognizer = UITapGestureRecognizer()

    private let tileSide: CGFloat

    private var prevSize: CGSize?

    public init(color: UIColor, tileSide: CGFloat = 4) {
        self.hsv = HSVColor(uiColor: color)
        self.marker = ColorMapControlMarker(color: color)
        self.tileSide = tileSide

        super.init(frame: .zero)

        // Setup layers
        colorMapLayer = CALayer(layer: self.layer)
        layer.insertSublayer(colorMapLayer, at: 0)

        // Setup gesture recognizers
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.addTarget(self, action: #selector(didPan(gesture:)))

        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(didTap(gesture:)))

        addSubview(marker)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let update = {
            self.updateColorMap()
            self.updateMarker()
        }

        if let prevSize = prevSize, prevSize != frame.size {
            update()
        } else if prevSize == nil {
            // If we have no previous size, our `hsv` is correct, but
            // we have never rendered the marker, so we must update the marker
            // with a position corresponding to our current `hsv`
            marker.center = point(from: HSVColor(h: hsv.h, s: hsv.s, v: hsv.v).uiColor, in: frame)
            update()
        }

        prevSize = frame.size
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 200)
    }

    @objc private func didTap(gesture: UITapGestureRecognizer) {
        feedbackGenerator.prepare()
        marker.center = gesture.location(in: self)
        updateMarker()
        feedbackGenerator.selectionChanged()
    }

    @objc private func didPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began || gesture.state == .ended {
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
        }

        if gesture.state == .changed || gesture.state == .ended {
            var location = gesture.location(in: self)
            location.x = min(max(0, location.x), frame.size.width)
            location.y = min(max(0, location.y), frame.size.height)
            marker.center = location
            marker.editing = gesture.state != .ended
            updateMarker()
        }
    }

    private func updateColorMap() {
        colorMap(with: frame.size, and: tileSide, hue: hsv.h, done: { image in
            self.colorMapImage = image
            self.colorMapLayer.frame = CGRect(origin: .zero, size: image.size)
            self.colorMapLayer.contents = image.cgImage
        })
    }

    private func updateMarker() {
        hsv = hsvFrom(point: marker.center, in: frame, withHue: self.hsv.h)
        marker.color = hsv.uiColor
    }

    // MARK: - Static functions

    private func colorMap(with size: CGSize, and tileSide: CGFloat, hue: CGFloat, done: @escaping ((UIImage) -> Void)) {
        DispatchQueue.global(qos: .userInteractive).async {
            let nbrPixelsX = size.width / tileSide
            let nbrPixelsY = size.height / tileSide
            var image: UIImage! = nil

            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            let context = UIGraphicsGetCurrentContext()!
            let imageRect = CGRect(origin: .zero, size: size)

            var hsvColor = HSVColor(h: hue, s: 0, v: 0)
            for y in stride(from: 0, to: nbrPixelsY, by: 1) {
                let v =  1 - (y / nbrPixelsY)
                hsvColor.v = self.valueTimingFunction?.get(t: v) ?? v

                for x in stride(from: 0, to: nbrPixelsX, by: 1) {
                    let s = x / nbrPixelsX
                    hsvColor.s = self.saturationTimingFunction?.get(t: s) ?? s

                    context.setFillColor(hsvColor.uiColor.cgColor)
                    context.fill(CGRect(x: tileSide * x + imageRect.origin.x,
                                        y: tileSide * y + imageRect.origin.y,
                                        width: tileSide,
                                        height: tileSide))
                }
            }

            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            DispatchQueue.main.async {
                done(image)
            }
        }
    }

    private func hsvFrom(point: CGPoint, in rect: CGRect, withHue hue: CGFloat) -> HSVColor {
        var hsv = HSVColor()
        hsv.h = hue
        let noramlizedX = point.x / rect.width
        let normalizedY = 1 - (point.y / rect.height) // Low -> dark, thus invert
        hsv.s = saturationTimingFunction?.get(t: noramlizedX) ?? noramlizedX
        hsv.v = valueTimingFunction?.get(t: normalizedY) ?? normalizedY
        return hsv
    }

    private func point(from color: UIColor, in rect: CGRect) -> CGPoint {
        let hsv = HSVColor(uiColor: color)
        let normalizedX = saturationTimingFunction?.t(for: hsv.s) ?? hsv.s
        let normalizedY = valueTimingFunction?.t(for: hsv.v) ?? hsv.v
        return CGPoint(x: normalizedX * rect.width, y: (1 - normalizedY) * rect.height)
    }

}
