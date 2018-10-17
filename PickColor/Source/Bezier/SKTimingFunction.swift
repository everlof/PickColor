//
//  SKTimingFunction.swift
//  Pods
//
//  Created by Takuya Okamoto on 2015/10/06.
//
//
// inspired by https://gist.github.com/raphaelschaad/6739676

import UIKit

// TODO: Change to:
// https://github.com/ehsan/mozilla-history/blob/master/content/smil/nsSMILKeySpline.cpp
//
// Taken from: https://gist.github.com/entotsu/bebc65e184ea109ddef6
// Which was inspired from: http://greweb.me/2012/02/bezier-curve-based-easing-functions-from-concept-to-implementation/

//
// Finding intersection
// https://math.stackexchange.com/questions/527005/find-value-of-t-at-a-point-on-a-cubic-bezier-curve?rq=1
// Try this one. I think it's still chapter 17, but rhe page numbering might be a bit different.
// https://scholarsarchive.byu.edu/facpub/1/

/**
 # CAMediaTimingFunction in Anywhere.
 All the cool animation curves from `CAMediaTimingFunction` but it is only available to use with CoreAnimation.
 This is the TimingFunction class like CAMediaTimingFunction available in AnyWhere.
 This is translated by [JavaScript](http://greweb.me/2012/02/bezier-curve-based-easing-functions-from-concept-to-implementation/).
 # Usage
 ``` swift
 let move = SKAction.moveTo(point, duration:2.0)
 let timingFunc = SKTimingFunction(controlPoints: 0.6, 0.0, 0.1, 0.6)
 move.timingFunction = {timingFunc.get($0)}
 ```
 */
public class SKTimingFunction {

    let mX1: CGFloat
    let mY1: CGFloat
    let mX2: CGFloat
    let mY2: CGFloat

    public init(controlPoints c1x: CGFloat, _ c1y: CGFloat, _ c2x: CGFloat, _ c2y: CGFloat) {
        self.mX1 = c1x
        self.mY1 = c1y
        self.mX2 = c2x
        self.mY2 = c2y
    }

    private func get(aX: CGFloat) -> CGFloat {
        if (mX1 == mY1 && mX2 == mY2) { return aX } // linear
        return calcBezier(aT: getTForX(aX: aX), mY1, mY2)
    }

    internal func get(t: CGFloat) -> CGFloat {
        return self.get(aX: CGFloat(t))
    }

    internal func t(for value: CGFloat) -> CGFloat {
        var min = CGFloat.greatestFiniteMagnitude
        var tMin: CGFloat = 0
        for t in stride(from: 0, through: 1, by: 0.001) {
            let valueForT = get(t: CGFloat(t))
            let diff = abs(valueForT - value)
            if diff < min {
                min = diff
                tMin = CGFloat(t)
            }
        }
        return tMin
    }

    private func A(aA1: CGFloat, _ aA2: CGFloat) -> CGFloat { return 1.0 - 3.0 * aA2 + 3.0 * aA1 }
    private func B(aA1: CGFloat, _ aA2: CGFloat) -> CGFloat { return 3.0 * aA2 - 6.0 * aA1 }
    private func C(aA1: CGFloat)               -> CGFloat { return 3.0 * aA1 }

    // Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
    private func calcBezier(aT: CGFloat, _ aA1: CGFloat, _ aA2: CGFloat) -> CGFloat {
        return ((A(aA1: aA1, aA2)*aT + B(aA1: aA1, aA2))*aT + C(aA1: aA1))*aT
    }

    // Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
    private func getSlope(aT: CGFloat, _ aA1: CGFloat, _ aA2: CGFloat) -> CGFloat {
        return 3.0 * A(aA1: aA1, aA2)*aT*aT + 2.0 * B(aA1: aA1, aA2) * aT + C(aA1: aA1)
    }

    private func getTForX(aX: CGFloat) -> CGFloat {
        // Newton raphson iteration
        var aGuessT = aX
        for _ in stride(from: 0, to: 4, by: 1) {
            let currentSlope = getSlope(aT: aGuessT, mX1, mX2)
            if (currentSlope == 0.0) {return aGuessT}
            let currentX = calcBezier(aT: aGuessT, mX1, mX2) - aX
            aGuessT -= currentX / currentSlope
        }
        return aGuessT
    }
}
