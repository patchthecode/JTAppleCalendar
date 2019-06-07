//
//  JTACMonthCell.swift
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
public protocol JTACCellMonthViewDelegate: class {
    func monthView(_ monthView: JTACCellMonthView,
                  drawingFor segmentRect: CGRect,
                  with date: Date,
                  dateOwner: DateOwner,
                  monthIndex: Int)
}

open class JTACMonthCell: UICollectionViewCell {
    @IBOutlet var monthView: JTACCellMonthView?
    weak var delegate: JTACCellMonthViewDelegate?
    
    func setupWith(configurationParameters: ConfigurationParameters,
                   month: Month,
                   delegate: JTACCellMonthViewDelegate) {
        guard let monthView = monthView else { assert(false); return }
        self.delegate = delegate
        monthView.setupWith(configurationParameters: configurationParameters,
                            month: month,
                            delegate: self)
    }
}

extension JTACMonthCell: JTACCellMonthViewDelegate {
    public func monthView(_ monthView: JTACCellMonthView,
                          drawingFor segmentRect: CGRect,
                          with date: Date,
                          dateOwner: DateOwner,
                          monthIndex: Int) {
        delegate?.monthView(monthView, drawingFor: segmentRect, with: date, dateOwner: dateOwner, monthIndex: monthIndex)
    }
}




open class JTACCellMonthView: UIView {
    var sectionInset = UIEdgeInsets.zero
    var month: Month!
    var configurationParameters: ConfigurationParameters!
    weak var delegate: JTACCellMonthViewDelegate?
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    
    func setupWith(configurationParameters: ConfigurationParameters, month: Month, delegate: JTACCellMonthViewDelegate? = nil) {
        self.configurationParameters = configurationParameters
        self.delegate = delegate
        self.month = month
        
        setNeedsDisplay()  // force reloading of the drawRect code to update the view.
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)

        var xCellOffset: CGFloat = 0
        var yCellOffset: CGFloat = 0
        
        let numberOfDaysInCurrentSection = month.sections.first!
        for dayCounter in 1...numberOfDaysInCurrentSection {
            
            let width = (frame.width - ((sectionInset.left / 7) + (sectionInset.right / 7))) / 7
            let height = (frame.height - sectionInset.top - sectionInset.bottom) / 6
            
            let rect = CGRect(x: xCellOffset, y: yCellOffset, width: width, height: height)
            guard let dateWithOwner = dateFromIndex(dayCounter - 1, month: month,
                                                    startOfMonthCache: configurationParameters.startDate,
                                                    endOfMonthCache: configurationParameters.endDate) else { continue }

            
            delegate?.monthView(self,
                                drawingFor: rect,
                                with: dateWithOwner.date,
                                dateOwner: dateWithOwner.owner,
                                monthIndex: month.index)

            xCellOffset += width
            
            if dayCounter == numberOfDaysInCurrentSection || dayCounter % maxNumberOfDaysInWeek == 0 {
                // We are at the last item in the section
                // && if we have headers
                xCellOffset = sectionInset.left
                yCellOffset += height
            }
        }
    }
    
    private func dateFromIndex(_ index: Int, month: Month, startOfMonthCache: Date, endOfMonthCache: Date) -> (date: Date, owner: DateOwner)? { // Returns nil if date is out of scope
        // Calculate the offset
        let offSet = month.inDates
        
        let dayIndex = month.startDayIndex + index - offSet
        var dateOwner: DateOwner
        
        guard let validDate = configurationParameters.calendar.date(byAdding: .day, value: dayIndex, to: startOfMonthCache) else { return nil }
        
        if index >= offSet && index < month.numberOfDaysInMonth + offSet {
            dateOwner = .thisMonth
        } else if index < offSet {
            // This is a preDate
            
            if validDate < startOfMonthCache {
                dateOwner = .previousMonthOutsideBoundary
            } else {
                dateOwner = .previousMonthWithinBoundary
            }
        } else {
            // This is a postDate
            if validDate > endOfMonthCache {
                dateOwner = .followingMonthOutsideBoundary
            } else {
                dateOwner = .followingMonthWithinBoundary
            }
        }
        return (validDate, dateOwner)
    }
}
