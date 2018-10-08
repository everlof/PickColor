//
//  ColorMapControl.swift
//  PickColor
//
//  Created by David Everlöf on 2018-10-08.
//  Copyright © 2018 David Everlöf. All rights reserved.
//

import UIKit

struct HSVColor {
    var h: CGFloat
    var s: CGFloat
    var v: CGFloat

    var uiColor: UIColor {
        return UIColor(hue: h, saturation: s, brightness: v, alpha: 1.0)
    }
}

class ColorMapControl: UIControl {

    func colorMap(with size: CGSize, and tileSide: CGFloat) -> UIImage {
        let nbrPixelsX = size.width / tileSide
        let nbrPixelsY = size.height / tileSide

        let colorMapSize = CGSize(width: nbrPixelsX * tileSide, height: nbrPixelsY * tileSide)

        let renderToContext: ((CGContext, CGRect) -> Void) = { context, rect in

            var pixelHSV = HSVColor(h: 1, s: 1, v: 1)
            for i in stride(from: 0, to: nbrPixelsX, by: 1) {
                let pixelX = CGFloat(i) / nbrPixelsX
                pixelHSV.h = pixelX
                context.setFillColor(pixelHSV.uiColor.cgColor)
                context.fill(CGRect(x: tileSide * i + rect.origin.x, y: rect.origin.y, width: tileSide, height: rect.height))
            }
        }


        /*
 int pixelCountX = (int) (size.width / tileSize);
 int pixelCountY = (int) (size.height / tileSize);
 CGSize colorMapSize = CGSizeMake(pixelCountX * tileSize, pixelCountY * tileSize);

 void(^renderToContext)(CGContextRef, CGRect) = ^(CGContextRef context, CGRect rect) {

 CGFloat margin = 0;

 HRHSVColor pixelHsv;
 pixelHsv.s = pixelHsv.v = 1;
 for (int i = 0; i < pixelCountX; ++i) {
 CGFloat pixelX = (CGFloat) i / pixelCountX;

 pixelHsv.h = pixelX;
 UIColor *color;
 color = [UIColor colorWithHue:pixelHsv.h
 saturation:pixelHsv.s
 brightness:pixelHsv.v
 alpha:1];
 CGContextSetFillColorWithColor(context, color.CGColor);
 CGContextFillRect(context, CGRectMake(tileSize * i + rect.origin.x, rect.origin.y, tileSize - margin, CGRectGetHeight(rect)));
 }

 CGFloat top;
 for (int j = 0; j < pixelCountY; ++j) {
 top = tileSize * j + rect.origin.y;
 CGFloat pixelY = (CGFloat) j / (pixelCountY - 1);
 CGFloat alpha = (pixelY * saturationUpperLimit);
 CGContextSetRGBFillColor(context, 1, 1, 1, alpha);
 CGContextFillRect(context, CGRectMake(rect.origin.x, top, CGRectGetWidth(rect), tileSize - margin));
 }
 };

 return [UIImage hr_imageWithSize:colorMapSize renderer:renderToContext];*/

        return UIImage(named: "ok")!
    }

}
