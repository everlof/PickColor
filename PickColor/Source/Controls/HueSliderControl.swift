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

protocol HueSliderControlDelegate: class {
    func hueSliderControl(_: HueSliderControl, didUpdateHueWithIntentEmit: Bool)
}

public class HueSliderControl: UIControl {

    // MARK: - Public variables

    public var hue: CGFloat {
        didSet {
            updateMarker()
        }
    }
    
    internal weak var delegate: HueSliderControlDelegate?

    // MARK: - Private variables

    private var feedbackGenerator = UISelectionFeedbackGenerator()

    private var renderingFrame: CGRect = .zero

    private var controlFrame: CGRect = .zero

    private let cursor: HueSliderControlMarker

    private lazy var sliderLayer: CAGradientLayer = {
        return CAGradientLayer(layer: self.layer)
    }()

    // MARK: - Overridden variables

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 14)
    }

    public init(color: UIColor) {
        self.cursor = HueSliderControlMarker(color: UIColor.clear)
        self.hue = HSVColor(uiColor: color).h
        super.init(frame: .zero)

        sliderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        sliderLayer.endPoint = CGPoint(x: 1, y: 0.5)
        sliderLayer.borderColor = UIColor.lightGray.cgColor
        sliderLayer.borderWidth = 1.0 / UIScreen.main.scale

        layer.addSublayer(sliderLayer)
        backgroundColor = .clear
        addSubview(cursor)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        addGestureRecognizer(tapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(panGestureRecognizer)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let frame = CGRect(origin: .zero, size: self.frame.size)
        renderingFrame = frame.inset(by: self.alignmentRectInsets)
        controlFrame = renderingFrame.insetBy(dx: 8, dy: 0)
        sliderLayer.frame = renderingFrame
        sliderLayer.cornerRadius = renderingFrame.size.height / 2
        sliderLayer.colors = stride(from: 0, to: 1, by: 0.1).map {
            UIColor(hue: $0, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor
        }
        updateMarker()
    }

    @objc func handleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            feedbackGenerator.prepare()
            let tapPoint = gesture.location(ofTouch: 0, in: self)
            update(tapPoint: tapPoint, shouldSendActions: true)
            updateMarker()
            feedbackGenerator.selectionChanged()
        }
    }

    var lastTapPoint: CGPoint?
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
        }

        if gesture.state == .changed || gesture.state == .ended {
            if gesture.numberOfTouches <= 0 {
                feedbackGenerator.prepare()
                cursor.editing = false
                feedbackGenerator.selectionChanged()
                if let lastTapPoint = lastTapPoint {
                    update(tapPoint: lastTapPoint, shouldSendActions: true)
                }
            } else {
                let tapPoint = gesture.location(ofTouch: 0, in: self)
                update(tapPoint: tapPoint, shouldSendActions: gesture.state == .ended)
                updateMarker()
                cursor.editing = true
                lastTapPoint = tapPoint
            }
        }
    }

    func update(tapPoint: CGPoint, shouldSendActions: Bool) {
        var tapPointInSlider = CGPoint(x: tapPoint.x - controlFrame.origin.x, y: tapPoint.y)
        tapPointInSlider.x = min(tapPointInSlider.x, controlFrame.size.width)
        tapPointInSlider.x = max(tapPointInSlider.x, 0)
        hue = tapPointInSlider.x / controlFrame.size.width
        delegate?.hueSliderControl(self, didUpdateHueWithIntentEmit: shouldSendActions)
    }

    func updateMarker() {
        cursor.center = CGPoint(x: hue * controlFrame.size.width + controlFrame.origin.x, y: frame.height / 2)
    }

    public override var alignmentRectInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }

    public override func alignmentRect(forFrame frame: CGRect) -> CGRect {
        return frame.inset(by: self.alignmentRectInsets)
    }

    public override func frame(forAlignmentRect alignmentRect: CGRect) -> CGRect {
        return alignmentRect.inset(by: UIEdgeInsets(top: -10, left: -20, bottom: -10, right: -20))
    }

}
