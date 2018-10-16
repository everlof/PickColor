//
//  Color+CoreDataProperties.swift
//  PickColor
//
//  Created by David Everlöf on 2018-10-16.
//  Copyright © 2018 David Everlöf. All rights reserved.
//
//

import Foundation
import CoreData


extension Color {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Color> {
        return NSFetchRequest<Color>(entityName: "Color")
    }

    @NSManaged public var blue: Float
    @NSManaged public var green: Float
    @NSManaged public var lastUsed: NSDate?
    @NSManaged public var red: Float

    var uiColor: UIColor {
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }

}
