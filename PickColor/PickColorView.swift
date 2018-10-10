//
//  PickColorView.swift
//  PickColor
//
//  Created by David Everlöf on 2018-10-08.
//  Copyright © 2018 David Everlöf. All rights reserved.
//

import Foundation

public class PickColorView: UIView {

    public let colorMap: ColorMapControl

    public init() {
        colorMap = ColorMapControl()
        colorMap.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)

        addSubview(colorMap)

        colorMap.topAnchor.constraint(equalTo: topAnchor).isActive = true
        colorMap.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        colorMap.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        colorMap.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
