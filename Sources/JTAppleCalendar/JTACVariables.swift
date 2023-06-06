//
//  JTACVariables.swift
//
//  Copyright (c) 2016-2020 JTAppleCalendar (https://github.com/patchthecode/JTAppleCalendar)
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

import Foundation
import UIKit

// Calculated Variables
extension JTACMonthView {
    /// Workaround for Xcode bug that prevents you from connecting the delegate in the storyboard.
    /// Remove this extra property once Xcode gets fixed.
    @IBOutlet public var ibCalendarDelegate: AnyObject? {
        get { return calendarDelegate as AnyObject? }
        set { calendarDelegate = newValue as? JTACMonthViewDelegate }
    }
    
    /// Workaround for Xcode bug that prevents you from connecting the delegate in the storyboard.
    /// Remove this extra property once Xcode gets fixed.
    @IBOutlet public var ibCalendarDataSource: AnyObject? {
        get { return calendarDataSource as AnyObject? }
        set { calendarDataSource = newValue as? JTACMonthViewDataSource }
    }
    
    @available(*, unavailable)
    /// Will not be used by subclasses
    open override var delegate: UICollectionViewDelegate? {
        get { return super.delegate }
        set { /* Do nothing */ }
    }
    
    @available(*, unavailable)
    /// Will not be used by subclasses
    open override var dataSource: UICollectionViewDataSource? {
        get { return super.dataSource }
        set {/* Do nothing */ }
    }
    
    /// Returns all selected dates
    public var selectedDates: [Date] {
        return selectedDatesSet.sorted()
    }
    
    var selectedDatesSet: Set<Date> {
        return Set(selectedCellData.values.map { $0.date })
    }
    
    var monthInfo: [Month] {
        get { return theData.months }
        set { theData.months = newValue }
    }
    
    var numberOfMonths: Int {
        return monthInfo.count
    }
    
    var totalDays: Int {
        return theData.totalDays
    }
             
    var calendarViewLayout: JTACMonthLayout {
        guard let layout = collectionViewLayout as? JTACMonthLayout else {
            developerError(string: "Calendar layout is not of type JTAppleCalendarMonthLayout.")
            return JTACMonthLayout(withDelegate: self)
        }
        return layout
    }
    
    var functionIsUnsafeSafeToRun: Bool {
        return !calendarLayoutIsLoaded || isScrollInProgress || isReloadDataInProgress
    }
    
    var calendarLayoutIsLoaded: Bool { return calendarViewLayout.isCalendarLayoutLoaded }
    var startDateCache: Date {
        guard let date = _cachedConfiguration?.startDate else {
            assert(false, "Attemped to access startDate when Datasource/delegate is not set yet. Returning todays's date")
            return Date()
        }
        return date
    }
    var endDateCache: Date           {
        guard let date = _cachedConfiguration?.endDate else {
            assert(false, "Attemped to access endDate when Datasource/delegate is not set yet. Returning todays's date")
            return Date()
        }
        return date
    }
    var calendar: Calendar {
        guard let calendar = _cachedConfiguration?.calendar else {
            assert(false, "Attemped to access calendar when Datasource/delegate is not set yet. Returning default value")
            return Calendar.current
        }
        return calendar
    }
}
