import Foundation

class BrightnessSliderControl: UIControl {

    private var _color: UIColor = .red

    var color: UIColor {
        get {
            var hsv = HSVColor(uiColor: _color)
            hsv.v = brightness
            return hsv.uiColor
        }
        set {
            set(color: newValue)
        }
    }

    var brightness: CGFloat = 0.5

    private lazy var sliderLayer: CAGradientLayer = {
        return CAGradientLayer(layer: self.layer)
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 10)
    }

    let cursor = ColorMapMarkerView()

    init() {
        super.init(frame: .zero)
        sliderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        sliderLayer.endPoint = CGPoint(x: 1, y: 0.5)
        sliderLayer.borderColor = UIColor.lightGray.cgColor
        sliderLayer.borderWidth = 1.0 / UIScreen.main.scale

        layer.addSublayer(sliderLayer)

        cursor.editingMagnification = 1.5
        addSubview(cursor)

        backgroundColor = .clear

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        addGestureRecognizer(tapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(panGestureRecognizer)
    }

    var renderingFrame: CGRect = .zero
    var controlFrame: CGRect = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = CGRect(origin: .zero, size: self.frame.size)
        renderingFrame = frame.inset(by: self.alignmentRectInsets)
        controlFrame = renderingFrame.insetBy(dx: 8, dy: 0)
        sliderLayer.frame = renderingFrame
        sliderLayer.cornerRadius = renderingFrame.size.height / 2
    }

    /*
 - (void)layoutSubviews {
 [super layoutSubviews];
 CGRect frame = (CGRect) {.origin = CGPointZero, .size = self.frame.size};
 _renderingFrame = UIEdgeInsetsInsetRect(frame, self.alignmentRectInsets);
 _controlFrame = CGRectInset(_renderingFrame, 8, 0);
 _brightnessCursor.center = CGPointMake(
 CGRectGetMinX(_controlFrame),
 CGRectGetMidY(_controlFrame));
 _sliderLayer.cornerRadius = _renderingFrame.size.height / 2;
 _sliderLayer.frame = _renderingFrame;
 [self updateCursor];
 }*/

/*- (void)setColor:(UIColor *)color {
 _color = color;

 CGFloat brightness;
 [_color getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
 _brightness = @(brightness);

 [self updateCursor];

 [CATransaction begin];
 [CATransaction setValue:(id) kCFBooleanTrue
 forKey:kCATransactionDisableActions];

 HRHSVColor hsvColor;
 HSVColorFromUIColor(_color, &hsvColor);
 UIColor *darkColorFromHsv = [UIColor colorWithHue:hsvColor.h saturation:hsvColor.s brightness:self.brightnessLowerLimit.floatValue alpha:1.0f];
 UIColor *lightColorFromHsv = [UIColor colorWithHue:hsvColor.h saturation:hsvColor.s brightness:1.0f alpha:1.0f];

 _sliderLayer.colors = @[(id) lightColorFromHsv.CGColor, (id) darkColorFromHsv.CGColor];

 [CATransaction commit];
 }*/

    private func set(color: UIColor) {
        _color = color
        let hsv = HSVColor(uiColor: color)
        self.brightness = hsv.v
        updateCursor()

        let darkColorFromHSV = UIColor(hue: hsv.h, saturation: hsv.s, brightness: 0.0, alpha: 1.0)
        let lightColorFromHSV = UIColor(hue: hsv.h, saturation: hsv.s, brightness: 1.0, alpha: 1.0)

        sliderLayer.colors = [ lightColorFromHSV.cgColor, darkColorFromHSV.cgColor ]
    }

    /*
 - (void)handleTap:(UITapGestureRecognizer *)sender {
 if (sender.state == UIGestureRecognizerStateEnded) {
 if (sender.numberOfTouches <= 0) {
 return;
 }
 CGPoint tapPoint = [sender locationOfTouch:0 inView:self];
 [self update:tapPoint];
 [self updateCursor];
 }
 }

 - (void)handlePan:(UIPanGestureRecognizer *)sender {
 if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateEnded) {
 if (sender.numberOfTouches <= 0) {
 _brightnessCursor.editing = NO;
 return;
 }
 CGPoint tapPoint = [sender locationOfTouch:0 inView:self];
 [self update:tapPoint];
 [self updateCursor];
 _brightnessCursor.editing = YES;
 }
 }*/

    @objc func handleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let tapPoint = gesture.location(ofTouch: 0, in: self)
            update(tapPoint: tapPoint)
            updateCursor()
        }
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed || gesture.state == .ended {
            if gesture.numberOfTouches <= 0 {
                cursor.editing = false
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
    }

    /*
 - (void)update:(CGPoint)tapPoint {
 CGFloat selectedBrightness = 0;
 CGPoint tapPointInSlider = CGPointMake(tapPoint.x - _controlFrame.origin.x, tapPoint.y);
 tapPointInSlider.x = MIN(tapPointInSlider.x, _controlFrame.size.width);
 tapPointInSlider.x = MAX(tapPointInSlider.x, 0);

 selectedBrightness = 1.0 - tapPointInSlider.x / _controlFrame.size.width;
 selectedBrightness = selectedBrightness * (1.0 - self.brightnessLowerLimit.floatValue) + self.brightnessLowerLimit.floatValue;
 _brightness = @(selectedBrightness);

 [self sendActionsForControlEvents:UIControlEventValueChanged];
 }

 - (void)updateCursor {
 CGFloat brightnessCursorX = (1.0f - (self.brightness.floatValue - self.brightnessLowerLimit.floatValue) / (1.0f - self.brightnessLowerLimit.floatValue));
 if (brightnessCursorX < 0) {
 return;
 }
 CGPoint point = CGPointMake(brightnessCursorX * _controlFrame.size.width + _controlFrame.origin.x, _brightnessCursor.center.y);
 _brightnessCursor.center = point;
 _brightnessCursor.color = self.color;
 }
*/

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
