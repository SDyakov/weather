//
//  statusButton.swift
//  Weather
//
//  Created by Admin on 09.10.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class StatusButton: UIButton {
    @IBInspectable var fillColor: UIColor = UIColor.red
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect)
        fillColor.setFill()
        path.fill()
    }
}
