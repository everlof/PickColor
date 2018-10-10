import UIKit

extension UIImage {

    static func colorMap(with size: CGSize, opaque: Bool = false, renderer: ((CGContext, CGRect) -> Void)) -> UIImage {
        var _size = size
        _size.height = _size.height == 0 ? 1 : _size.height
        _size.width = _size.width == 0 ? 1 : _size.width

        UIGraphicsBeginImageContextWithOptions(_size, opaque, 0)
        let context = UIGraphicsGetCurrentContext()!
        let imageRect = CGRect(origin: .zero, size: CGSize(width: _size.width, height: _size.height))
        renderer(context, imageRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

}

