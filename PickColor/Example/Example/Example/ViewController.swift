//
//  ViewController.swift
//  Example
//
//  Created by David Everlöf on 2018-10-08.
//  Copyright © 2018 David Everlöf. All rights reserved.
//

import UIKit
import PickColor

class ViewController: UIViewController {

    let pickColorView: PickColorView

    init() {
        pickColorView = PickColorView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(pickColorView)
        pickColorView.translatesAutoresizingMaskIntoConstraints = false
        pickColorView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        pickColorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pickColorView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        pickColorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

}

