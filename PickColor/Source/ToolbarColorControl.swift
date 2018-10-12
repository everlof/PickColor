import UIKit

public protocol ToolbarColorControlDelegate: class {
    func toolbarColorControl(_: ToolbarColorControl, didUpdateBrightness brightness: CGFloat)
    func toolbarColorControl(_: ToolbarColorControl, didSelectRecentColor color: UIColor)
    func toolbarColorControl(_: ToolbarColorControl, didManuallyEnterColor color: UIColor)
}

public class ToolbarColorControl: UIControl,
    RecentColorsCollectionViewDelegate,
    ColorTextFieldDelegate {

    public weak var delegate: ToolbarColorControlDelegate?

    public let currentColorView = CurrentColorView()

    public let recentColorsCollectionView = RecentColorsCollectionView()

    public let brightnessSlider: BrightnessSliderControl

    public var hexFont: UIFont? {
        get {
            return currentColorView.colorHexTextField.font
        }
        set {
            currentColorView.colorHexTextField.font = hexFont
        }
    }

    public var color: UIColor {
        didSet {
            currentColorView.color = color
            brightnessSlider.color = color
            sendActions(for: .valueChanged)
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

    public init(color: UIColor) {
        self.color = color
        currentColorView.color = color

        brightnessSlider = BrightnessSliderControl(color: color)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        currentColorView.colorHexTextField.colorTextFieldDelegate = self

        // addSubview(blurEffectView)
        addSubview(currentColorView)
        addSubview(recentColorsCollectionView)
        addSubview(brightnessSlider)

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

        brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        brightnessSlider.leftAnchor.constraint(equalTo: currentColorView.rightAnchor, constant: 14).isActive = true
        brightnessSlider.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        brightnessSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true

        brightnessSlider.addTarget(self, action: #selector(brightnessChanged), for: .valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func brightnessChanged() {
        var hsv = HSVColor(uiColor: color)
        hsv.v = brightnessSlider.brightness
        color = hsv.uiColor
        delegate?.toolbarColorControl(self, didUpdateBrightness: brightnessSlider.brightness)
    }

    // MARK: - RecentColorsCollectionViewDelegate

    public func didSelectRecent(color: UIColor) {
        self.color = color
        delegate?.toolbarColorControl(self, didSelectRecentColor: color)
    }

    // MARK: - ColorTextFieldDelegate

    func didInput(color: UIColor) {
        self.color = color
        delegate?.toolbarColorControl(self, didManuallyEnterColor: color)
    }

}
