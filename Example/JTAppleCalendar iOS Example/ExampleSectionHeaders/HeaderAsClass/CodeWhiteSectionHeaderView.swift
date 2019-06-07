//
//  CodeWhiteSectionHeaderView.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-07-15.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import JTAppleCalendar

class CodeWhiteSectionHeaderView: JTACMonthReusableView {
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 1.0, green: 2.5, blue: 0.3, alpha: 1.0)
        let r1 = CGRect(x: 0, y: 0, width: 25, height: 25)         // Size
        context.addRect(r1)
        context.fillPath()
        context.setStrokeColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
        context.addEllipse(in: CGRect(x: 0, y: 0, width: 25, height: 25))
        context.strokePath()
    }

}
