//
//  CodePinkSectionHeaderView.swift
//  JTAppleCalendar
//
//  Created by Jeron Thomas on 2016-07-15.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import JTAppleCalendar

class CodePinkSectionHeaderView: JTAppleHeaderView {
    
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        CGContextSetRGBFillColor(context, 1.0, 0.5, 0.0, 1.0);
        let r1 = CGRectMake(0 , 0, 25, 25);         // Size
        CGContextAddRect(context,r1);
        CGContextFillPath(context);
        
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 0.5, 1.0);
        CGContextAddEllipseInRect(context, CGRectMake(0 , 0, 25, 25));
        CGContextStrokePath(context);
     }
    
   

}
