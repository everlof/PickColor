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
