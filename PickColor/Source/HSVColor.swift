import UIKit

struct HSVColor {
    var h: CGFloat
    var s: CGFloat
    var v: CGFloat

    var uiColor: UIColor {
        return UIColor(hue: h, saturation: s, brightness: v, alpha: 1.0)
    }

    init() {
        self.h = 0
        self.s = 0
        self.v = 0
    }

    init(h: CGFloat, s: CGFloat, v: CGFloat) {
        self.h = h
        self.s = s
        self.v = v
    }

    init(uiColor: UIColor) {
        self.h = 0
        self.s = 0
        self.v = 0
        uiColor.getHue(&self.h, saturation: &self.s, brightness: &self.v, alpha: nil)
    }
}
