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

import UIKit

public extension UIColor {

    public var name: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: nil)

        r = r * 255
        g = g * 255
        b = b * 255

        var shortestDistance = CGFloat.greatestFiniteMagnitude
        var bestMatchingName = Resource.colorMap.first!.value

        for (hex, name) in Resource.colorMap {
            let mask = 0x000000FF
            let r2 = CGFloat(Int(hex >> 16) & mask)
            let g2 = CGFloat(Int(hex >> 8) & mask)
            let b2 = CGFloat(Int(hex) & mask)


            let squaredEuclideanDistance = pow(r2 - r, 2) + pow(g2 - g, 2) + pow(b2 - b, 2)

            if squaredEuclideanDistance < shortestDistance {
                shortestDistance = squaredEuclideanDistance
                bestMatchingName = name
            }
        }

        return bestMatchingName
    }

}
