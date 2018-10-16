import UIKit

public struct HSVColor: Codable {

    public var h: CGFloat
    public var s: CGFloat
    public var v: CGFloat

    public var uiColor: UIColor {
        return UIColor(hue: h, saturation: s, brightness: v, alpha: 1.0)
    }

    public init() {
        self.h = 0
        self.s = 0
        self.v = 0
    }

    public init(h: CGFloat, s: CGFloat, v: CGFloat) {
        self.h = h
        self.s = s
        self.v = v
    }

    public init(uiColor: UIColor) {
        self.h = 0
        self.s = 0
        self.v = 0
        uiColor.getHue(&self.h, saturation: &self.s, brightness: &self.v, alpha: nil)
    }

}

extension HSVColor: Equatable {
    
    public static func == (lhs: HSVColor, rhs: HSVColor) -> Bool {
        return lhs.h == rhs.h && lhs.s == rhs.s && lhs.v == rhs.v
    }

}
