//
//  JTAppleCalendarVariables.swift
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

// Calculated Variables
extension JTAppleCalendarView {
    /// Workaround for Xcode bug that prevents you from connecting the delegate in the storyboard.
    /// Remove this extra property once Xcode gets fixed.
    @IBOutlet public var ibCalendarDelegate: AnyObject? {
        get { return calendarDelegate }
        set { calendarDelegate = newValue as? JTAppleCalendarViewDelegate }
    }
    
    /// Workaround for Xcode bug that prevents you from connecting the delegate in the storyboard.
    /// Remove this extra property once Xcode gets fixed.
    @IBOutlet public var ibCalendarDataSource: AnyObject? {
        get { return calendarDataSource }
        set { calendarDataSource = newValue as? JTAppleCalendarViewDataSource }
    }
    
    /// Returns all selected dates
    open var selectedDates: [Date] {
        return selectedDatesSet.sorted()
    }
    
    var selectedDatesSet: Set<Date> {
        return Set(selectedCellData.values.map { $0.date })
    }
    
    var monthInfo: [Month] {
        get { return theData.months }
        set { theData.months = monthInfo }
    }
    
    var numberOfMonths: Int {
        return monthInfo.count
    }
    
    var totalDays: Int {
        return theData.totalDays
    }
    
    var calendarViewLayout: JTAppleCalendarLayout {
        guard let layout = collectionViewLayout as? JTAppleCalendarLayout else {
            developerError(string: "Calendar layout is not of type JTAppleCalendarLayout.")
            return JTAppleCalendarLayout(withDelegate: self)
        }
        return layout
    }
    
    var functionIsUnsafeSafeToRun: Bool {
        return !isCalendarLayoutLoaded || isScrollInProgress || isReloadDataInProgress
    }
    
    var isCalendarLayoutLoaded: Bool { return calendarViewLayout.isCalendarLayoutLoaded }
    var startDateCache: Date         { return _cachedConfiguration.startDate }
    var endDateCache: Date           { return _cachedConfiguration.endDate }
    var calendar: Calendar           { return _cachedConfiguration.calendar }

    

}
