import UIKit

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

    let brightnessSlider: BrightnessSliderControl

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

    public init(color: UIColor) {
        brightnessSlider = BrightnessSliderControl(color: color)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        currentColorView.colorHexTextField.colorTextFieldDelegate = self

        addSubview(blurEffectView)
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
