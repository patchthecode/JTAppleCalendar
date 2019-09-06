//
//  CodePinkSectionHeaderView.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-07-15.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import JTAppleCalendar
import UIKit

class CodePinkSectionHeaderView: JTACMonthReusableView {
    override func draw(_: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        let r1 = CGRect(x: 0, y: 0, width: 25, height: 25)
        context.addRect(r1)
        context.fillPath()
        context.setStrokeColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
        context.addEllipse(in: CGRect(x: 0, y: 0, width: 25, height: 25))
        context.strokePath()
    }
}
