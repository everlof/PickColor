//
//  PickColorView.swift
//  PickColor
//
//  Created by David Everlöf on 2018-10-08.
//  Copyright © 2018 David Everlöf. All rights reserved.
//

import Foundation

public class PickColorView: UIView {

    public let colorMapControl: ColorMapControl

    public init() {
        colorMapControl = ColorMapControl(color: UIColor(hexString: "#357f4e")!)
        colorMapControl.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)

        addSubview(colorMapControl)

        colorMapControl.topAnchor.constraint(equalTo: topAnchor).isActive = true
        colorMapControl.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        colorMapControl.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        colorMapControl.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        // colorMapControl.brightness = 0.5
        colorMapControl.addTarget(self, action: #selector(colorMapChangedColor), for: .valueChanged)
    }

    @objc func colorMapChangedColor() {
        print("=> \(colorMapControl.color.hex)")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
