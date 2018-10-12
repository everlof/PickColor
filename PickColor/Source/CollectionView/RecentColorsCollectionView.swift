import UIKit

public protocol RecentColorsCollectionViewDelegate: class {
    func didSelectRecent(color: UIColor)
}

public class RecentColorsCollectionView: UICollectionView,
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

    // TODO Should come from CoreData/Persistant source
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

    private func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentColorCollectionViewCell.identifier, for: indexPath) as! RecentColorCollectionViewCell
        cell.color = data[indexPath.row]
        cell.delegate = self
        return cell
    }

    // MARK: - RecentColorCollectionViewCellDelegate
    public func didSelectRecent(color: UIColor) {
        recentColorDelegate?.didSelectRecent(color: color)
    }

}
