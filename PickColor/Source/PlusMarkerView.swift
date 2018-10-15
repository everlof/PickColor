import UIKit

extension CGRect {

    var center: CGPoint {
        return CGPoint(x: origin.x + width / 2, y: origin.y + height / 2)
    }

}

public class PlusMarkerView: UIView {

    // MARK: - Static configuration

    public static var defaultDiagonal: CGFloat = 20.0

    public static var defaultEditingMagnification: CGFloat = 3.0

    public static var defaultCircleDiameter: CGFloat = 4.0

    // MARK:  - Public variables

    /// The diagonal of `self`.
    public var diagonal = PlusMarkerView.defaultDiagonal {
        didSet {
            size = CGSize(width: diagonal, height: diagonal)
        }
    }

    public var circleDiameter = PlusMarkerView.defaultCircleDiameter {
        didSet {
            update(animated: true)
        }
    }

    public var editingMagnification: CGFloat = PlusMarkerView.defaultEditingMagnification {
        didSet {
            update(animated: true)
        }
    }

    public var circleBoarderColor = UIColor(white: 0.65, alpha: 1.0) {
        didSet {
//            backLayer.borderColor = circleBoarderColor.cgColor
        }
    }

    public var circleColor = UIColor(white: 1.0, alpha: 0.7) {
        didSet {
//            backLayer.backgroundColor = circleColor.cgColor
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

    private var size = CGSize(width: PlusMarkerView.defaultDiagonal, height: PlusMarkerView.defaultDiagonal) {
        didSet {
            update(animated: true)
        }
    }

    private let backLayer = CAShapeLayer()

    private let colorLayer = CALayer()

    public init(color: UIColor) {
        self.color = color
        super.init(frame: CGRect(origin: .zero, size: size))
        backgroundColor = .clear
        isUserInteractionEnabled = false

        let backFrame = CGRect(origin: .zero, size: self.frame.size)
        backLayer.frame = backFrame

        layer.addSublayer(backLayer)
        layer.addSublayer(colorLayer)

        update(animated: false)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func backPathIn(rect: CGRect) -> CGPath {
        let path = UIBezierPath()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))

        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))

        path.addArc(withCenter: rect.center, radius: rect.width / 4, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)

        return path.cgPath
    }

    private func update(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0.0 ) {
            self.colorLayer.backgroundColor = self.color.cgColor
            let backFrame = CGRect(origin: .zero, size: self.bounds.size)

            self.backLayer.strokeColor = UIColor.black.cgColor
            self.backLayer.path = self.backPathIn(rect: backFrame)


            if self.editing {
                // We don't want to change the borders, thus we must adjust their size
                // by dividing it's original size by the magnification we apply

                self.transform = CGAffineTransform.identity.scaledBy(x: self.editingMagnification, y: self.editingMagnification)
//                self.colorLayer.frame = backFrame.insetBy(dx: self.circleDiameter / self.editingMagnification,
//                                                          dy: self.circleDiameter / self.editingMagnification)
                self.backLayer.lineWidth = (1 / UIScreen.main.scale) / self.editingMagnification
            } else {
                self.transform = CGAffineTransform.identity
                self.backLayer.lineWidth = (1 / UIScreen.main.scale)
            }

            self.colorLayer.frame = backFrame.insetBy(dx: self.circleDiameter + 1.0, dy: self.circleDiameter + 1.0)
            self.colorLayer.cornerRadius = self.colorLayer.frame.height / 2.0
        }
    }

}
