import Foundation

public class ColorMarker: UIView {

    public var size = CGSize(width: 28, height: 28) {
        didSet {
            update(animated: true)
        }
    }

    private let backLayer = CALayer()

    private let colorLayer = CALayer()

    public var editingMagnification: CGFloat = 3.0

    var color: UIColor = .white {
        didSet {
            update(animated: true)
        }
    }

    var circleBoarderColor = UIColor(white: 0.65, alpha: 1.0) {
        didSet {
            backLayer.borderColor = circleBoarderColor.cgColor
        }
    }

    var circleColor = UIColor(white: 1.0, alpha: 0.7) {
        didSet {
            backLayer.backgroundColor = circleColor.cgColor
        }
    }

    var editing: Bool = false {
        didSet { update(animated: true) }
    }

    public init() {
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
                self.colorLayer.frame = backFrame.insetBy(dx: 5.5 / self.editingMagnification, dy: 5.5 / self.editingMagnification)
                self.backLayer.borderWidth = (1 / UIScreen.main.scale) / self.editingMagnification
            } else {
                self.transform = CGAffineTransform.identity
                self.colorLayer.frame = backFrame.insetBy(dx: 5.5, dy: 5.5)
                self.backLayer.borderWidth = 1 / UIScreen.main.scale
            }

            self.colorLayer.cornerRadius = self.colorLayer.frame.height / 2.0
        }
    }

}
