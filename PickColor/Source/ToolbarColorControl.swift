import UIKit

public protocol ToolbarColorControlDelegate: class {
    func toolbarColorControl(_: ToolbarColorControl, didUpdateHue hue: CGFloat)
    func toolbarColorControl(_: ToolbarColorControl, didSelectRecentColor color: UIColor)
    func toolbarColorControl(_: ToolbarColorControl, didManuallyEnterColor color: UIColor)
}

public class ToolbarColorControl: UIControl,
    RecentColorsCollectionViewDelegate,
    ColorTextFieldDelegate {

    public weak var delegate: ToolbarColorControlDelegate?

    public let currentColorView = CurrentColorView()

    public let recentColorsCollectionView = RecentColorsCollectionView()

    public let hueSlider: HueSliderControl

    public var hexFont: UIFont? {
        get { return currentColorView.colorHexTextField.font }
        set { currentColorView.colorHexTextField.font = hexFont }
    }

    public var selectedColor: UIColor {
        get {
            return hsv.uiColor
        }
        set {
            hsv = HSVColor(uiColor: newValue)
        }
    }

    private var hsv: HSVColor {
        didSet {
            if oldValue != hsv {
                currentColorView.color = hsv.uiColor
                sendActions(for: .valueChanged)
            }
        }
    }

//    lazy var blurEffectView: UIVisualEffectView = {
//        let blurEffect = UIBlurEffect(style: .prominent)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        return blurEffectView
//    }()

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: currentColorView.intrinsicContentSize.height + 24)
    }

    public init(selectedColor: UIColor) {
        hsv = HSVColor(uiColor: selectedColor)
        currentColorView.color = selectedColor
        hueSlider = HueSliderControl(color: selectedColor)
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        currentColorView.colorHexTextField.colorTextFieldDelegate = self

        // addSubview(blurEffectView)
        addSubview(currentColorView)
        addSubview(recentColorsCollectionView)
        addSubview(hueSlider)

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

        hueSlider.translatesAutoresizingMaskIntoConstraints = false
        hueSlider.leftAnchor.constraint(equalTo: currentColorView.rightAnchor, constant: 14).isActive = true
        hueSlider.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        hueSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true

        hueSlider.addTarget(self, action: #selector(hueChanged), for: .valueChanged)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func hueChanged() {
        hsv.h = hueSlider.hue
        delegate?.toolbarColorControl(self, didUpdateHue: hueSlider.hue)
    }

    // MARK: - RecentColorsCollectionViewDelegate

    public func didSelectRecent(color: UIColor) {
        hsv = HSVColor(uiColor: color)
        delegate?.toolbarColorControl(self, didSelectRecentColor: color)
    }

    // MARK: - ColorTextFieldDelegate

    public func didInput(color: UIColor) {
        hsv = HSVColor(uiColor: color)
        delegate?.toolbarColorControl(self, didManuallyEnterColor: color)
    }

}
