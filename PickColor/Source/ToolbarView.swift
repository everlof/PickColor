import UIKit

public protocol ToolbarViewDelegate: class {
    func toolbarView(_: ToolbarView, didUpdateHue hue: CGFloat)
    func toolbarView(_: ToolbarView, didSelectRecentColor color: UIColor)
    func toolbarView(_: ToolbarView, didManuallyEnterColor color: UIColor)
}

public class ToolbarView: UIView,
    RecentColorsCollectionViewDelegate,
    ColorTextFieldDelegate {

    public weak var delegate: ToolbarViewDelegate?

    public let currentColorView: CurrentColorView

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
            }
        }
    }

//    lazy var blurEffectView: UIVisualEffectView = {
//        let blurEffect = UIBlurEffect(style: .dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        return blurEffectView
//    }()

//    public override var intrinsicContentSize: CGSize {
//        return CGSize(width: UIView.noIntrinsicMetric, height: currentColorView.intrinsicContentSize.height + 24)
//    }

    public init(selectedColor: UIColor) {
        self.currentColorView = CurrentColorView(color: selectedColor)
        hsv = HSVColor(uiColor: selectedColor)
        currentColorView.color = selectedColor
        hueSlider = HueSliderControl(color: selectedColor)
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        currentColorView.colorHexTextField.colorTextFieldDelegate = self

//        addSubview(blurEffectView)
//        addSubview(currentColorView)
        addSubview(recentColorsCollectionView)
        addSubview(hueSlider)
//
//        currentColorView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
//        currentColorView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
//        currentColorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
//
        recentColorsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        recentColorsCollectionView.recentColorDelegate = self
        recentColorsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        recentColorsCollectionView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        recentColorsCollectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        recentColorsCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        recentColorsCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        recentColorsCollectionView.bottomAnchor.constraint(equalTo: hueSlider.topAnchor, constant: -20).isActive = true

        hueSlider.translatesAutoresizingMaskIntoConstraints = false

        hueSlider.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        hueSlider.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        hueSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true

        hueSlider.addTarget(self, action: #selector(hueChanged), for: .valueChanged)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func hueChanged() {
        hsv.h = hueSlider.hue
        delegate?.toolbarView(self, didUpdateHue: hueSlider.hue)
    }

    // MARK: - RecentColorsCollectionViewDelegate

    public func didSelectRecent(color: UIColor) {
        hsv = HSVColor(uiColor: color)
        delegate?.toolbarView(self, didSelectRecentColor: color)
    }

    // MARK: - ColorTextFieldDelegate

    public func didInput(color: UIColor) {
        hsv = HSVColor(uiColor: color)
        delegate?.toolbarView(self, didManuallyEnterColor: color)
    }

}
