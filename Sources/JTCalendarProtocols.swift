//
//  JTCalendarProtocols.swift
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

/// Default delegate functions
public extension JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool { return true }
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool { return true }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {}
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {}
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {}
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        assert(false, "You have implemted a header size function, but forgot to implement the `headerViewForDateRange` function")
        return JTAppleCollectionReusableView()
    }
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? { return nil }
    func sizeOfDecorationView(indexPath: IndexPath) -> CGRect { return .zero }
    func scrollDidEndDecelerating(for calendar: JTAppleCalendarView) {}
    func calendarDidScroll(_ calendar: JTAppleCalendarView) {}
}

/// The JTAppleCalendarViewDataSource protocol is adopted by an
/// object that mediates the application’s data model for a
/// the JTAppleCalendarViewDataSource object. data source provides the
/// the calendar-view object with the information it needs to construct and
/// then modify it self
public protocol JTAppleCalendarViewDataSource: class {
    /// Asks the data source to return the start and end boundary dates
    /// as well as the calendar to use. You should properly configure
    /// your calendar at this point.
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    /// - returns:
    ///     - ConfigurationParameters instance:
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters
}

/// The delegate of a JTAppleCalendarView object must adopt the
/// JTAppleCalendarViewDelegate protocol Optional methods of the protocol
/// allow the delegate to manage selections, and configure the cells
public protocol JTAppleCalendarViewDelegate: class {
    /// Asks the delegate if selecting the date-cell with a specified date is
    /// allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool

    /// Asks the delegate if de-selecting the
    /// date-cell with a specified date is allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool

    /// Tells the delegate that a date-cell with a specified date was selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///             This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState)
    /// Tells the delegate that a date-cell
    /// with a specified date was de-selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///             This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState)

    /// Tells the delegate that the JTAppleCalendar view
    /// scrolled to a segment beginning and ending with a particular date
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - startDate: The date at the start of the segment.
    ///     - endDate: The date at the end of the segment.
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo)

    /// Tells the delegate that the JTAppleCalendar is about to display
    /// a date-cell. This is the point of customization for your date cells
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the cell.
    ///     - cellState: The month the date-cell belongs to.
    ///     - indexPath: use this value when dequeing cells
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell

    /// Tells the delegate that the JTAppleCalendar is about to
    /// display a header. This is the point of customization for your headers
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the header.
    ///     - indexPath: use this value when dequeing cells
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView
    
    /// Informs the delegate that the user just lifted their finger from swiping the calendar
    func scrollDidEndDecelerating(for calendar: JTAppleCalendarView)
    
    /// Tells the delegate that a scroll occured
    func calendarDidScroll(_ calendar: JTAppleCalendarView)
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize?
    func sizeOfDecorationView(indexPath: IndexPath) -> CGRect
}
