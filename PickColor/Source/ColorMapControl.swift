import UIKit

struct HSVColor {
    var h: CGFloat
    var s: CGFloat
    var v: CGFloat

    var uiColor: UIColor {
        return UIColor(hue: h, saturation: s, brightness: v, alpha: 1.0)
    }

    init(h: CGFloat, s: CGFloat, v: CGFloat) {
        self.h = h
        self.s = s
        self.v = v
    }

    init(uiColor: UIColor) {
        self.h = 0
        self.s = 0
        self.v = 0
        uiColor.getHue(&self.h, saturation: &self.s, brightness: &self.v, alpha: nil)
    }
}

public class ColorMapControl: UIControl, ControlBoardViewDelegate {

    let marker = ColorMapMarkerView()

    public var selectedColor: UIColor {
        didSet {
            if oldValue != selectedColor {
                controlBoardScroller.currentColor = selectedColor
                sendActions(for: .valueChanged)
                controlBoardScroller.topControlBoardView.brightnessSlider.color = selectedColor
            }
        }
    }

    let feedbackGenerator = UISelectionFeedbackGenerator()

    var colorMapLayer: CALayer!
    var colorMapImage: UIImage // brightness = 1.0

    var colorMapBackgroundLayer: CALayer!
    var backgroundImage: UIImage // brightness = 0.0

    var boundsObserver: NSKeyValueObservation!

    let saturationUpperLimit: CGFloat = 0.95

    let brightness: CGFloat = 1

    let panGestureRecognizer = UIPanGestureRecognizer()

    let tapGestureRecognizer = UITapGestureRecognizer()

    let tileSide: CGFloat

    let controlBoardScroller = ControlBoardScrollView()

    var size: CGSize {
        didSet {
            if oldValue != size {
                didChangeSize()
            }
        }
    }

    public init(initialColor: UIColor = .red,tileSide: CGFloat = 1) {
        selectedColor = .red
        self.tileSide = tileSide
        size = CGSize(width: 1, height: 1)
        colorMapImage = ColorMapControl.colorMap(with: CGSize(width: 1, height: 1), and: tileSide, saturationUpperLimit: saturationUpperLimit)
        backgroundImage = ColorMapControl.backgroundColorMap(with: CGSize(width: 1, height: 1), and: tileSide)
        super.init(frame: .zero)

        colorMapLayer = CALayer(layer: self.layer)
        colorMapBackgroundLayer = CALayer(layer: self.layer)

        layer.insertSublayer(colorMapBackgroundLayer, at: 0)
        layer.insertSublayer(colorMapLayer, at: 1)

        boundsObserver = observe(\.bounds, changeHandler: { (observing, change) in
            self.size = self.bounds.size
        })

        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.addTarget(self, action: #selector(didPan(gesture:)))

        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(didTap(gesture:)))

        addSubview(marker)

        controlBoardScroller.controlBoardViewDelegate = self
        addSubview(controlBoardScroller)
        controlBoardScroller.translatesAutoresizingMaskIntoConstraints = false
        controlBoardScroller.topAnchor.constraint(equalTo: topAnchor).isActive = true
        controlBoardScroller.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        controlBoardScroller.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        controlBoardScroller.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    @objc func didTap(gesture: UITapGestureRecognizer) {
        feedbackGenerator.prepare()
        updateSelection(point: gesture.location(in: self), isEnding: true)
        feedbackGenerator.selectionChanged()
    }

    @objc func didPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began || gesture.state == .ended {
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
        }

        if gesture.state == .changed || gesture.state == .ended {
            var location = gesture.location(in: self)
            location.x = min(max(0, location.x), frame.size.width)
            location.y = min(max(0, location.y), frame.size.height)
            updateSelection(point: location, isEnding: gesture.state == .ended)
        }
    }

    func updateSelection(point: CGPoint, isEnding: Bool) {
        let pixelCountX = Int(frame.size.width / tileSide)
        let pixelCountY = Int(frame.size.height / tileSide)

        let pixelX = (point.x / tileSide) / CGFloat(pixelCountX)
        let pixelY = (point.y / tileSide) / CGFloat(pixelCountY - 1)

        let color = HSVColor(h: pixelX, s: 1.0 - (pixelY * saturationUpperLimit), v: brightness)
        selectedColor = color.uiColor
        marker.color = color.uiColor
        marker.center = point
        marker.editing = !isEnding

        // controlBoardScroller.frameMoving(marker.frame)
    }

    func didChangeSize() {
        guard size != .zero else { return }
        colorMapImage = ColorMapControl.colorMap(with: frame.size, and: tileSide, saturationUpperLimit: saturationUpperLimit)
        backgroundImage = ColorMapControl.backgroundColorMap(with: frame.size, and: tileSide)

        colorMapLayer.frame = CGRect(origin: .zero, size: colorMapImage.size)
        colorMapLayer.contents = colorMapImage.cgImage

        colorMapBackgroundLayer.frame = CGRect(origin: .zero, size: backgroundImage.size)
        colorMapBackgroundLayer.contents = backgroundImage.cgImage

        controlBoardScroller.adjustFor(size: bounds.size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func colorMap(with size: CGSize, and tileSide: CGFloat, saturationUpperLimit: CGFloat) -> UIImage {
        let nbrPixelsX = size.width / tileSide
        let nbrPixelsY = size.height / tileSide

        let colorMapSize = CGSize(width: nbrPixelsX * tileSide, height: nbrPixelsY * tileSide)

        let renderToContext: ((CGContext, CGRect) -> Void) = { context, rect in
            var pixelHSV = HSVColor(h: 1, s: 1, v: 1)
            for i in stride(from: 0, to: nbrPixelsX, by: 1) {
                let pixelX = CGFloat(i) / nbrPixelsX
                pixelHSV.h = pixelX
                context.setFillColor(pixelHSV.uiColor.cgColor)
                context.fill(CGRect(x: tileSide * i + rect.origin.x, y: rect.origin.y, width: tileSide, height: rect.height))
            }

            var top: CGFloat = 0
            for j in stride(from: 0, to: nbrPixelsY, by: 1) {
                top = tileSide * j + rect.origin.y
                let pixelY = CGFloat(j) / (nbrPixelsY - 1)
                let alpha = (pixelY * saturationUpperLimit)
                context.setFillColor(red: 1, green: 1, blue: 1, alpha: alpha)
                context.fill(CGRect(x: rect.origin.x, y: top, width: rect.width, height: tileSide))
            }
        }

        return UIImage.renderImage(with: colorMapSize, renderer: renderToContext)
    }

    static func backgroundColorMap(with size: CGSize, and tileSide: CGFloat) -> UIImage {
        let nbrPixelsX = size.width / tileSide
        let nbrPixelsY = size.height / tileSide

        let colorMapSize = CGSize(width: nbrPixelsX * tileSide, height: nbrPixelsY * tileSide)

        let renderToContext: ((CGContext, CGRect) -> Void) = { context, rect in
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)

            var height: CGFloat = 0
            context.setFillColor(gray: 0.0, alpha: 1.0)

            for j in stride(from: 0, to: nbrPixelsY, by: 1) {
                height = tileSide * j + rect.origin.y
                for i in stride(from: 0, to: nbrPixelsX, by: 1) {
                    let rect = CGRect(x: tileSide * i + rect.origin.x,
                                      y: height,
                                      width: tileSide,
                                      height: tileSide)
                    context.fill(rect)
                }
            }
        }

        return UIImage.renderImage(with: colorMapSize, renderer: renderToContext)
    }

    // MARK: - ControlBoardViewDelegate

    func controlBoardView(_: ControlBoardView, didSelectRecent color: UIColor) {
        feedbackGenerator.prepare()
        selectedColor = color
        feedbackGenerator.selectionChanged()
    }

    func controlBoardView(_: ControlBoardView, didType color: UIColor) {
        feedbackGenerator.prepare()
        selectedColor = color
        feedbackGenerator.selectionChanged()
    }

}
