import Foundation

class BrightnessSliderControl: UIControl {

    // MARK: - Public variables

    public var color: UIColor {
        get {
            var hsv = HSVColor(uiColor: _color)
            hsv.v = brightness
            return hsv.uiColor
        }
        set {
            set(color: newValue)
        }
    }

    public var brightness: CGFloat = 0.5

    // MARK: - Private variables

    private var feedbackGenerator = UISelectionFeedbackGenerator()

    private var _color: UIColor = .red

    private var renderingFrame: CGRect = .zero

    private var controlFrame: CGRect = .zero

    private let cursor: MarkerView

    private lazy var sliderLayer: CAGradientLayer = {
        return CAGradientLayer(layer: self.layer)
    }()

    // MARK: - Overridden variables

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 10)
    }

    public init(color: UIColor) {
        self.cursor = MarkerView(color: color)
        super.init(frame: .zero)
        set(color: color)
        sliderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        sliderLayer.endPoint = CGPoint(x: 1, y: 0.5)
        sliderLayer.borderColor = UIColor.lightGray.cgColor
        sliderLayer.borderWidth = 1.0 / UIScreen.main.scale

        layer.addSublayer(sliderLayer)
        cursor.editingMagnification = 1.5
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

    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = CGRect(origin: .zero, size: self.frame.size)
        renderingFrame = frame.inset(by: self.alignmentRectInsets)
        controlFrame = renderingFrame.insetBy(dx: 8, dy: 0)
        sliderLayer.frame = renderingFrame
        sliderLayer.cornerRadius = renderingFrame.size.height / 2
        updateCursor()
    }

    private func set(color: UIColor) {
        _color = color
        let hsv = HSVColor(uiColor: color)
        self.brightness = hsv.v
        updateCursor()

        let darkColorFromHSV = UIColor(hue: hsv.h, saturation: hsv.s, brightness: 0.0, alpha: 1.0)
        let lightColorFromHSV = UIColor(hue: hsv.h, saturation: hsv.s, brightness: 1.0, alpha: 1.0)

        sliderLayer.colors = [ lightColorFromHSV.cgColor, darkColorFromHSV.cgColor ]
    }

    @objc func handleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            feedbackGenerator.prepare()
            let tapPoint = gesture.location(ofTouch: 0, in: self)
            update(tapPoint: tapPoint)
            updateCursor()
            feedbackGenerator.selectionChanged()
        }
    }

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
            } else {
                let tapPoint = gesture.location(ofTouch: 0, in: self)
                update(tapPoint: tapPoint)
                updateCursor()
                cursor.editing = true
            }
        }
    }

    func update(tapPoint: CGPoint) {
        var tapPointInSlider = CGPoint(x: tapPoint.x - controlFrame.origin.x, y: tapPoint.y)
        tapPointInSlider.x = min(tapPointInSlider.x, controlFrame.size.width)
        tapPointInSlider.x = max(tapPointInSlider.x, 0)

        brightness = 1.0 - tapPointInSlider.x / controlFrame.size.width
        sendActions(for: .valueChanged)
    }

    func updateCursor() {
        let brightnessCursorX = 1.0 - brightness
        cursor.color = color
        cursor.center = CGPoint(x: brightnessCursorX * controlFrame.size.width + controlFrame.origin.x, y: frame.height / 2)
        cursor.center = CGPoint(x: brightnessCursorX * controlFrame.size.width + controlFrame.origin.x, y: frame.height / 2)
    }

    override var alignmentRectInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }

    override func alignmentRect(forFrame frame: CGRect) -> CGRect {
        return frame.inset(by: self.alignmentRectInsets)
    }

    override func frame(forAlignmentRect alignmentRect: CGRect) -> CGRect {
        return alignmentRect.inset(by: UIEdgeInsets(top: -10, left: -20, bottom: -10, right: -20))
    }

}
