import UIKit

extension UIImage {

    func colorMap(with size: CGSize, opaque: Bool, renderer: ((CGContext, CGRect) -> Void)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
        let context = UIGraphicsGetCurrentContext()!
        let imageRect = CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height))
        renderer(context, imageRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

}

/*
 + (UIImage *)hr_imageWithSize:(CGSize)size opaque:(BOOL)opaque renderer:(renderToContext)renderer {
 UIImage *image;

 UIGraphicsBeginImageContextWithOptions(size, opaque, 0);

 CGContextRef context = UIGraphicsGetCurrentContext();

 CGRect imageRect = CGRectMake(0.f, 0.f, size.width, size.height);

 renderer(context, imageRect);

 image = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return image;
 }*/
