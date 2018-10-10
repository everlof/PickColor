import UIKit

protocol RecentColorCollectionViewCellDelegate: class {
    func didSelectRecent(color: UIColor)
}

class RecentColorCollectionViewCell: UICollectionViewCell {

    static let identifier = "RecentColorCollectionViewCell"

    weak var delegate: RecentColorCollectionViewCellDelegate?

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
        delegate?.didSelectRecent(color: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol RecentColorsCollectionViewDelegate: class {
    func didSelectRecent(color: UIColor)
}

class RecentColorsCollectionView: UICollectionView,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    RecentColorCollectionViewCellDelegate {

    var size: CGSize = .zero {
        didSet {
            if oldValue != size {
                didChangeSize()
            }
        }
    }

    weak var recentColorDelegate: RecentColorsCollectionViewDelegate?

    let flowLayout = UICollectionViewFlowLayout()

    let data: [UIColor] = [ .red, .brown, .orange, .green, .blue, .gray, .purple, .cyan, .magenta ]

    var boundsObserver: NSKeyValueObservation!

    init() {
        super.init(frame: .zero, collectionViewLayout: flowLayout)

        delegate = self
        dataSource = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear

        flowLayout.scrollDirection = .horizontal

        register(RecentColorCollectionViewCell.self, forCellWithReuseIdentifier: RecentColorCollectionViewCell.identifier)

        reloadData()
        layoutIfNeeded()

        boundsObserver = observe(\.bounds, changeHandler: { (observing, change) in
            self.size = self.bounds.size
        })
    }

    func didChangeSize() {
        flowLayout.itemSize = CGSize(width: frame.height, height: frame.height)
        flowLayout.invalidateLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentColorCollectionViewCell.identifier, for: indexPath) as! RecentColorCollectionViewCell
        cell.color = data[indexPath.row]
        cell.delegate = self
        return cell
    }

    // MARK: - RecentColorCollectionViewCellDelegate
    func didSelectRecent(color: UIColor) {
        recentColorDelegate?.didSelectRecent(color: color)
    }

}
