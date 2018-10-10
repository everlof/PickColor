import UIKit

protocol ColorTextFieldDelegate: class {
    func didInput(color: UIColor)
}

class ColorTextField: UITextField, UITextFieldDelegate {

    private var prevText: String?

    weak var colorTextFieldDelegate: ColorTextFieldDelegate?

    let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: superSize.width, height: superSize.height + 18)
    }

    init() {
        super.init(frame: .zero)
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = text, let color = UIColor(hexString: text) {
            // We have an OK color!
            colorTextFieldDelegate?.didInput(color: color)
            print(color.hex)
        } else {
            feedbackGenerator.prepare()
            text = prevText
            feedbackGenerator.impactOccurred()

            backgroundColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = .black
            }
        }
        resignFirstResponder()
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        prevText = text
    }

}

class ControlBoardScroller: UIScrollView {

    let contentView = UIView()

    private let topControlBoardView = ControlBoardView()

    private let bottomControlBoardView = ControlBoardView()

    weak var controlBoardViewDelegate: ControlBoardViewDelegate? {
        get {
            return topControlBoardView.controlBoardViewDelegate ?? bottomControlBoardView.controlBoardViewDelegate
        }
        set {
            topControlBoardView.controlBoardViewDelegate = newValue
            bottomControlBoardView.controlBoardViewDelegate = newValue
        }
    }

    public var currentColor: UIColor = .red {
        didSet {
            topControlBoardView.currentColor = currentColor
            bottomControlBoardView.currentColor = currentColor
        }
    }

    init() {
        super.init(frame: .zero)

        topControlBoardView.translatesAutoresizingMaskIntoConstraints = false
        bottomControlBoardView.translatesAutoresizingMaskIntoConstraints = false

        isScrollEnabled = false
//        isUserInteractionEnabled = false

        addSubview(contentView)
        contentView.addSubview(topControlBoardView)
        contentView.addSubview(bottomControlBoardView)

        topControlBoardView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        topControlBoardView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        topControlBoardView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        bottomControlBoardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomControlBoardView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        bottomControlBoardView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let hitView = super.hitTest(point, with: event)
//        if hitView is PaddedTextField {
//            return hitView
//        }
//        return nil
//    }

    func adjustFor(size: CGSize) {
        let contentSize = CGSize(width: size.width, height: size.height + topControlBoardView.intrinsicContentSize.height)
        contentView.frame = CGRect(origin: .zero, size: contentSize)
        self.contentSize = contentSize
    }

//    func frameMoving(_ frame: CGRect) {
//        let bottomFrame =
//            bottomControlBoardView.frame
//                .applying(CGAffineTransform.identity.translatedBy(x: 0, y: -bottomControlBoardView.frame.height))
//
//        if topControlBoardView.frame.intersects(frame) {
//            scrollRectToVisible(bottomControlBoardView.frame, animated: false)
//        } else if bottomFrame.intersects(frame) {
//            scrollRectToVisible(topControlBoardView.frame, animated: false)
//        }
//    }

}

class CurrentColorView: UIView {

    fileprivate var color: UIColor = .red {
        didSet {
            backgroundView.backgroundColor = color
            colorHexTextField.text = color.hex
        }
    }

    private let containerView = UIStackView()

    internal let colorHexTextField = ColorTextField()

    internal let backgroundView = UIView()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 80, height: 120)
    }

    init() {
        super.init(frame: .zero)
        containerView.axis = .vertical
        translatesAutoresizingMaskIntoConstraints = false

        layer.masksToBounds = true
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        layer.cornerRadius = 3.0

        backgroundColor = .white
        colorHexTextField.textAlignment = .center

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

}

protocol ControlBoardViewDelegate: class {
    func controlBoardView(_: ControlBoardView, didSelectRecent color: UIColor)
    func controlBoardView(_: ControlBoardView, didType color: UIColor)
}

public class ControlBoardView: UIView,
    RecentColorsCollectionViewDelegate,
ColorTextFieldDelegate {

    weak var controlBoardViewDelegate: ControlBoardViewDelegate?

    let currentColorView = CurrentColorView()

    let recentColorsCollectionView = RecentColorsCollectionView()

    public var hexFont: UIFont? {
        get {
            return currentColorView.colorHexTextField.font
        }
        set {
            currentColorView.colorHexTextField.font = hexFont
        }
    }

    var currentColor: UIColor = .red {
        didSet {
            currentColorView.color = currentColor
        }
    }

    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: currentColorView.intrinsicContentSize.height + 24)
    }

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        currentColorView.colorHexTextField.colorTextFieldDelegate = self

        addSubview(blurEffectView)
        addSubview(currentColorView)
        addSubview(recentColorsCollectionView)

        currentColorView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        currentColorView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
        currentColorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true

        recentColorsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        recentColorsCollectionView.recentColorDelegate = self
        recentColorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        recentColorsCollectionView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        recentColorsCollectionView.leftAnchor.constraint(equalTo: currentColorView.rightAnchor).isActive = true
        recentColorsCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        recentColorsCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - RecentColorsCollectionViewDelegate

    func didSelectRecent(color: UIColor) {
        controlBoardViewDelegate?.controlBoardView(self, didSelectRecent: color)
    }

    // MARK: - ColorTextFieldDelegate

    func didInput(color: UIColor) {
        controlBoardViewDelegate?.controlBoardView(self, didType: color)
    }

}
