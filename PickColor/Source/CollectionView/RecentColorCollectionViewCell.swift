// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import UIKit

public protocol RecentColorCollectionViewCellDelegate: class {
    func didSelectRecent(color: UIColor)
}

/// Cell that is used to present a color.
public class RecentColorCollectionViewCell: UICollectionViewCell {

    // MARK: - Static variables

    /// Reuse identifier
    public static let identifier = "RecentColorCollectionViewCell"

    // MARK: - Public variables

    /// Delegate for when this cell is "tapped"
    public weak var delegate: RecentColorCollectionViewCellDelegate?

    /// The color that this cell represents.
    public var color: UIColor = UIColor.clear {
        didSet {
            backgroundColor = color
        }
    }

    // MARK: - Private variables

    private var feedbackGenerator = UISelectionFeedbackGenerator()

    private let button = UIButton(type: .system)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }

    @objc func didPressButton() {
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
        delegate?.didSelectRecent(color: color)
    }

}
