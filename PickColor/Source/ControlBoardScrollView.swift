import UIKit

//class ControlBoardScrollView: UIScrollView {
//
//    let contentView = UIView()
//
//    internal let topControlBoardView = ControlBoardView()
//
//    internal let bottomControlBoardView = ControlBoardView()
//
//    weak var controlBoardViewDelegate: ControlBoardViewDelegate? {
//        get {
//            return topControlBoardView.controlBoardViewDelegate ?? bottomControlBoardView.controlBoardViewDelegate
//        }
//        set {
//            topControlBoardView.controlBoardViewDelegate = newValue
//            bottomControlBoardView.controlBoardViewDelegate = newValue
//        }
//    }
//
//    public var currentColor: UIColor = .red {
//        didSet {
//            topControlBoardView.currentColor = currentColor
//            bottomControlBoardView.currentColor = currentColor
//        }
//    }
//
//    init() {
//        super.init(frame: .zero)
//
//        topControlBoardView.translatesAutoresizingMaskIntoConstraints = false
//        bottomControlBoardView.translatesAutoresizingMaskIntoConstraints = false
//
//        isScrollEnabled = false
//        //        isUserInteractionEnabled = false
//
//        addSubview(contentView)
//        contentView.addSubview(topControlBoardView)
//        contentView.addSubview(bottomControlBoardView)
//
//        topControlBoardView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
//        topControlBoardView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
//        topControlBoardView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
//
//        bottomControlBoardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
//        bottomControlBoardView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
//        bottomControlBoardView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    //    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//    //        let hitView = super.hitTest(point, with: event)
//    //        if hitView is PaddedTextField {
//    //            return hitView
//    //        }
//    //        return nil
//    //    }
//
//    func adjustFor(size: CGSize) {
//        let contentSize = CGSize(width: size.width, height: size.height + topControlBoardView.intrinsicContentSize.height)
//        contentView.frame = CGRect(origin: .zero, size: contentSize)
//        self.contentSize = contentSize
//    }
//
//    //    func frameMoving(_ frame: CGRect) {
//    //        let bottomFrame =
//    //            bottomControlBoardView.frame
//    //                .applying(CGAffineTransform.identity.translatedBy(x: 0, y: -bottomControlBoardView.frame.height))
//    //
//    //        if topControlBoardView.frame.intersects(frame) {
//    //            scrollRectToVisible(bottomControlBoardView.frame, animated: false)
//    //        } else if bottomFrame.intersects(frame) {
//    //            scrollRectToVisible(topControlBoardView.frame, animated: false)
//    //        }
//    //    }
//
//}
