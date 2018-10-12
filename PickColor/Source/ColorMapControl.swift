import UIKit

public class ColorMapControl: UIControl {

    // MARK: - Static configuration

    public static var defaultSaturationUpperLimit: CGFloat = 1.0

    // MARK: Public variables

    public let marker: MarkerView

    public var color: UIColor {
        didSet {
            if oldValue != color {
                brightness = HSVColor(uiColor: color).v
                updateColorCursor()
                marker.color = color
                sendActions(for: .valueChanged)
            }
        }
    }

    public var brightness: CGFloat {
        didSet {
            if brightness != oldValue {
                var hsv = HSVColor(uiColor: color)
                hsv.v = brightness
                color = hsv.uiColor
                updateBrightness()
            }
        }
    }

    // MARK: Private variables

    private let feedbackGenerator = UISelectionFeedbackGenerator()

    private var colorMapLayer: CALayer!

    private var colorMapImage: UIImage

    private var colorMapBackgroundLayer: CALayer!

    private var backgroundImage: UIImage

    private var boundsObserver: NSKeyValueObservation!

    private let saturationUpperLimit = ColorMapControl.defaultSaturationUpperLimit

    private let panGestureRecognizer = UIPanGestureRecognizer()

    private let tapGestureRecognizer = UITapGestureRecognizer()

    private let tileSide: CGFloat

    private var size: CGSize {
        didSet {
            if oldValue != size {
                didChangeSize()
            }
        }
    }

    public init(color: UIColor, tileSide: CGFloat = 1) {
        self.color = color
        self.brightness = HSVColor(uiColor: color).v
        self.marker = MarkerView(color: color)
        self.tileSide = tileSide

        // Need something != .zero, since image-rendring functions below don't like
        // to create images of with `width` or `height` 0.
        // After auto-layout has done its job, we'll listen to the resizing
        // and regenrate the images

        self.size = CGSize(width: 1, height: 1)

        // Setup colors maps
        colorMapImage = ColorMapControl.colorMap(with: self.size,
                                                 and: tileSide,
                                                 saturationUpperLimit: saturationUpperLimit)

        backgroundImage = ColorMapControl.backgroundColorMap(with: self.size, and: tileSide)

        super.init(frame: .zero)

        // Setup layers
        colorMapLayer = CALayer(layer: self.layer)
        colorMapBackgroundLayer = CALayer(layer: self.layer)
        layer.insertSublayer(colorMapBackgroundLayer, at: 0)
        layer.insertSublayer(colorMapLayer, at: 1)

        // Observe changing size
        boundsObserver = observe(\.bounds, changeHandler: { (observing, change) in
            self.size = self.bounds.size
        })

        // Setup gesture recognizers
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.addTarget(self, action: #selector(didPan(gesture:)))

        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(didTap(gesture:)))

        // Add subview
        addSubview(marker)

        // Update UI according to model (color + brightness)
        updateBrightness()
        updateColorCursor()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateBrightness() {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        colorMapLayer.opacity = Float(brightness)
        CATransaction.commit()
    }

    @objc private func didTap(gesture: UITapGestureRecognizer) {
        feedbackGenerator.prepare()
        updateSelection(point: gesture.location(in: self), isEnding: true)
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
            updateSelection(point: location, isEnding: gesture.state == .ended)
            updateColorCursor()
        }
    }

    private func updateSelection(point: CGPoint, isEnding: Bool) {
        let pixelCountX = Int(frame.size.width / tileSide)
        let pixelCountY = Int(frame.size.height / tileSide)

        let pixelX = (point.x / tileSide) / CGFloat(pixelCountX)
        let pixelY = (point.y / tileSide) / CGFloat(pixelCountY - 1)

        let color = HSVColor(h: pixelX, s: 1.0 - (pixelY * saturationUpperLimit), v: brightness)
        self.color = color.uiColor

        marker.color = color.uiColor
        marker.center = point
        marker.editing = !isEnding
    }

    private func didChangeSize() {
        guard size != .zero else { return }
        colorMapImage = ColorMapControl.colorMap(with: frame.size, and: tileSide, saturationUpperLimit: saturationUpperLimit)
        backgroundImage = ColorMapControl.backgroundColorMap(with: frame.size, and: tileSide)

        colorMapLayer.frame = CGRect(origin: .zero, size: colorMapImage.size)
        colorMapLayer.contents = colorMapImage.cgImage

        colorMapBackgroundLayer.frame = CGRect(origin: .zero, size: backgroundImage.size)
        colorMapBackgroundLayer.contents = backgroundImage.cgImage

        updateColorCursor()
    }

    private static func colorMap(with size: CGSize, and tileSide: CGFloat, saturationUpperLimit: CGFloat) -> UIImage {
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

    private static func backgroundColorMap(with size: CGSize, and tileSide: CGFloat) -> UIImage {
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
                    context.fill(CGRect(x: tileSide * i + rect.origin.x,
                                        y: height,
                                        width: tileSide,
                                        height: tileSide))
                }
            }
        }

        return UIImage.renderImage(with: colorMapSize, renderer: renderToContext)
    }

    private func updateColorCursor() {
        let hsvColor = HSVColor(uiColor: color)
        print("Update for color=\(color.hex), oldPosition=\(marker.center)")

        let nbrPixelsX = frame.size.width / tileSide
        let nbrPixelsY = frame.size.height / tileSide

        var newPosition: CGPoint = .zero
        var hue = hsvColor.h
        if hue == 1 {
            hue = 0
        }

        print(hsvColor.h, hsvColor.s, hsvColor.v)

        newPosition.x = hue * nbrPixelsX * tileSide + (tileSide / 2.0)
        newPosition.y = (1.0 - hsvColor.s) * (1.0 / saturationUpperLimit) * (nbrPixelsY - 1) * tileSide + (tileSide / 2.0)

        let cgPoint = CGPoint(x: CGFloat(Int(newPosition.x / tileSide)) * tileSide,
                              y: CGFloat(Int(newPosition.y / tileSide)) * tileSide)

        marker.center = cgPoint
    }

}
