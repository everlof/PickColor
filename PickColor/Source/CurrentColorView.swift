import UIKit

public protocol CurrentColorViewDelegate: class {
    func currentColorView(_ : CurrentColorView, didSelectColor: UIColor)
}

public class CurrentColorView: UIView {

    public var color: UIColor {
        didSet {
            backgroundView.backgroundColor = color
            colorHexTextField.text = color.hex
        }
    }

    public weak var delegate: CurrentColorViewDelegate?

    private let containerView = UIStackView()

    internal let colorHexTextField = ColorTextField()

    internal let backgroundView = UIView()

    internal let tapGestureRecognizer = UITapGestureRecognizer()

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 80, height: 100)
    }

    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        containerView.axis = .vertical
        translatesAutoresizingMaskIntoConstraints = false

        layer.masksToBounds = true
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        layer.cornerRadius = 3.0

        backgroundColor = .white
        colorHexTextField.textAlignment = .center

        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(didTap))

        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        containerView.addArrangedSubview(backgroundView)
        containerView.addArrangedSubview(colorHexTextField)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTap() {
        delegate?.currentColorView(self, didSelectColor: color)
    }

}
