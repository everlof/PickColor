import UIKit

protocol RecentColorCollectionViewCellDelegate: class {
    func didSelectRecent(color: UIColor)
}

class RecentColorCollectionViewCell: UICollectionViewCell {

    static let identifier = "RecentColorCollectionViewCell"

    weak var delegate: RecentColorCollectionViewCellDelegate?

    private var feedbackGenerator = UISelectionFeedbackGenerator()

    let button = UIButton(type: .system)

    var color: UIColor = .red {
        didSet {
            backgroundColor = color
            layer.borderColor = color.withAlphaComponent(0.5).cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        layer.masksToBounds = true
        layer.borderWidth = 1 / UIScreen.main.scale

        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }

    @objc func didPressButton() {
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
        delegate?.didSelectRecent(color: color)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
