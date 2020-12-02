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

    /// The "hue" of the whole color map, changing this value
    /// will result in the whole map being redrawn with the new hue.
    ///
    /// A value in the range 0 - 1
    private(set) var hue: CGFloat

    /// The "saturation" of the color map. This is the saturation
    /// that is currently selected by the marker in the view.
    ///
    /// A value in the range 0 - 1
    private(set) var saturation: CGFloat

    /// The "value" of the color map. This is the value
    /// that is currently selected by the marker in the view.
    ///
    /// A value in the range 0 - 1
    private(set) var value: CGFloat

    // MARK: Private variables

    private var updateTimer: Timer?

    private var hsv: HSVColor {
        return HSVColor(h: hue, s: saturation, v: value)
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
        let hsv = HSVColor(uiColor: color)
        self.hue = hsv.h
        self.saturation = hsv.s
        self.value = hsv.v
        self.marker = ColorMapControlMarker(color: color)
        self.tileSide = tileSide

        super.init(frame: .zero)

        // Setup layers
        colorMapLayer = CALayer(layer: self.layer)
        layer.insertSublayer(colorMapLayer, at: 0)

        // Setup gesture recognizers
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.addTarget(self, action: #selector(handle(gesture:)))

        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(handle(gesture:)))

        addSubview(marker)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Set saturation and value of this control, updates the markers position to match the values provided
    /// - Parameters:
    ///   - saturation: saturation to move marker to
    ///   - value: value to move marker to
    func set(saturation: CGFloat, andValue value: CGFloat) {
        self.saturation = saturation
        self.value = value
        marker.center = point(from: hsv, in: frame)
        marker.color = hsv.uiColor
    }

    /// Set the hue of the whole color-map shown currently
    /// - Parameter hue: hue to change the whole color-map to
    func set(hue: CGFloat) {
        self.hue = hue
        updateColorMap()
        marker.color = hsv.uiColor
    }

    private func setSaturationAndValueFromLocation(location: CGPoint, shouldSendActions: Bool) {
        let hsv = hsvFrom(point: location, in: frame, withHue: hue)
        saturation = hsv.s
        value = hsv.v
        if shouldSendActions {
            sendActions(for: .valueChanged)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let update = {
            self.updateColorMap()
            self.marker.color = self.hsv.uiColor
        }

        if frame.size.width == 0 || frame.size.height == 0 {
            // Ignore
        } else if let prevSize = prevSize, prevSize != frame.size {
            update()
        } else if prevSize == nil {
            // If we have no previous size, our `hsv` is correct, but
            // we have never rendered the marker, so we must update the marker
            // with a position corresponding to our current `hsv`
            marker.center = point(from: HSVColor(h: hsv.h, s: hsv.s, v: hsv.v), in: frame)
            update()
        }

        prevSize = frame.size
    }

    @objc private func handle(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            updateTimer = Timer.scheduledTimer(withTimeInterval: 0.20, repeats: true, block: { _ in
                self.sendActions(for: .valueChanged)
            })
        }

        if gesture.state == .changed || gesture.state == .ended {
            var location = gesture.location(in: self)
            location.x = min(max(0, location.x), frame.size.width)
            location.y = min(max(0, location.y), frame.size.height)

            marker.center = location
            setSaturationAndValueFromLocation(location: location, shouldSendActions: gesture.state == .ended)
            marker.color = hsv.uiColor
        }

        marker.editing = gesture.state != .ended
        if gesture.state == .ended || gesture.state == .cancelled {
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }

    private func updateColorMap() {
        colorMap(with: frame.size, and: tileSide, hue: hsv.h, done: { image in
            self.colorMapImage = image
            self.colorMapLayer.frame = CGRect(origin: .zero, size: self.frame.size)
            self.colorMapLayer.contents = image?.cgImage
        })
    }

    private func colorMap(with size: CGSize, and tileSide: CGFloat, hue: CGFloat, done: @escaping ((UIImage?) -> Void)) {
        if size.width == 0 || size.height == 0 {
            done(nil)
            return
        }

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
                hsvColor.v = v
                for x in stride(from: 0, to: nbrPixelsX, by: 1) {
                    let s = x / nbrPixelsX
                    hsvColor.s = s
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
        hsv.s = noramlizedX
        hsv.v = normalizedY

        hsv.s = min(max(hsv.s, 0), 1)
        hsv.v = min(max(hsv.v, 0), 1)

        return hsv
    }

    private func point(from hsv: HSVColor, in rect: CGRect) -> CGPoint {
        let normalizedX = hsv.s
        let normalizedY = hsv.v

        let x = normalizedX * rect.width
        let y = (1 - normalizedY) * rect.height

        if x.isNaN || y.isNaN {
            return .zero
        } else {
            return CGPoint(x: x, y: y)
        }
    }

}
