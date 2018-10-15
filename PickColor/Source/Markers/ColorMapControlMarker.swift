import UIKit

public class ColorMapControlMarker: UIView {

    // MARK: - Static configuration

    public static var defaultDiagonal: CGFloat = 28.0

    public static var defaultEditingMagnification: CGFloat = 2.0

    public static var defaultBorderWidth: CGFloat = 5.5

    // MARK:  - Public variables

    /// The diagonal of `self`.
    public var diagonal = ColorMapControlMarker.defaultDiagonal {
        didSet {
            size = CGSize(width: diagonal, height: diagonal)
        }
    }

    public var borderWidth = ColorMapControlMarker.defaultBorderWidth {
        didSet {
            update(animated: true)
        }
    }

    public var editingMagnification: CGFloat = ColorMapControlMarker.defaultEditingMagnification {
        didSet {
            update(animated: true)
        }
    }

    public var circleBoarderColor = UIColor(white: 0.65, alpha: 1.0) {
        didSet {
            backLayer.borderColor = circleBoarderColor.cgColor
        }
    }

    public var circleColor = UIColor(white: 1.0, alpha: 0.7) {
        didSet {
            backLayer.backgroundColor = circleColor.cgColor
        }
    }

    public var editing: Bool = false {
        didSet {
            update(animated: true)
        }
    }

    public var color: UIColor {
        didSet {
            update(animated: true)
        }
    }

    // MARK: - Private variables

    private var size = CGSize(width: HueSliderControlMarker.defaultDiagonal, height: HueSliderControlMarker.defaultDiagonal) {
        didSet {
            update(animated: true)
        }
    }

    private let backLayer = CALayer()

    private let colorLayer = CALayer()

    public init(color: UIColor) {
        self.color = color
        super.init(frame: CGRect(origin: .zero, size: size))
        backgroundColor = .clear
        isUserInteractionEnabled = false

        let backFrame = CGRect(origin: .zero, size: self.frame.size)
        backLayer.frame = backFrame
        backLayer.cornerRadius = frame.height / 2.0
        backLayer.borderColor = circleBoarderColor.cgColor
        backLayer.backgroundColor = circleColor.cgColor

        layer.addSublayer(backLayer)
        layer.addSublayer(colorLayer)
        
        update(animated: false)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func update(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0.0 ) {
            self.colorLayer.backgroundColor = self.color.cgColor
            let backFrame = CGRect(origin: .zero, size: self.bounds.size)

            if self.editing {
                // We don't want to change the borders, thus we must adjust their size
                // by dividing it's original size by the magnification we apply

                self.transform = CGAffineTransform.identity.scaledBy(x: self.editingMagnification, y: self.editingMagnification)
                self.colorLayer.frame = backFrame.insetBy(dx: self.borderWidth / self.editingMagnification, dy: self.borderWidth / self.editingMagnification)
                self.backLayer.borderWidth = (1 / UIScreen.main.scale) / self.editingMagnification
            } else {
                self.transform = CGAffineTransform.identity
                self.colorLayer.frame = backFrame.insetBy(dx: self.borderWidth, dy: self.borderWidth)
                self.backLayer.borderWidth = 1 / UIScreen.main.scale
            }

            self.colorLayer.cornerRadius = self.colorLayer.frame.height / 2.0
        }
    }

}
