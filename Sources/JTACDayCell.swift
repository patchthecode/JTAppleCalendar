//
//  JTACDayCell.swift
//
//  Copyright (c) 2016-2017 JTAppleCalendar (https://github.com/patchthecode/JTAppleCalendar)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

/// The JTAppleDayCell class defines the attributes and
/// behavior of the cells that appear in JTAppleCalendarMonthView objects.
@available(*, unavailable, renamed: "JTACDayCell")
open class JTAppleCell: UICollectionViewCell{}
open class JTACDayCell: UICollectionViewCell {
    @available(*, message: "Using isSelected only to determing when selection occurs is ok. For other cases please use cellState.isSelected to avoid synchronization issues.")
    open override var isSelected: Bool {
        get { return super.isSelected }
        set { super.isSelected = newValue}
    }
    
    /// Cell view that will be customized
	public override init(frame: CGRect) {
		super.init(frame: frame)
	}

	/// Returns an object initialized from data in a given unarchiver.
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
    
    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
