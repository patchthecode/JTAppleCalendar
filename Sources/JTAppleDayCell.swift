//
//  JTAppleDayCell.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

/// The JTAppleDayCell class defines the attributes and
/// behavior of the cells that appear in JTAppleCalendarView objects.
open class JTAppleDayCell: UICollectionViewCell, JTAppleReusableViewProtocol {

	var view: JTAppleDayCellView?

    func updateCellView(_ cellInsetX: CGFloat, cellInsetY: CGFloat) {
        let vFrame = self.frame.insetBy(dx: cellInsetX, dy: cellInsetY)
        view!.frame = vFrame
        view!.center = CGPoint(x: self.bounds.size.width * 0.5,
                               y: self.bounds.size.height * 0.5)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	/// Returns an object initialized from data in a given unarchiver.
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

}
