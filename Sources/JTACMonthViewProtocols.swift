//
//  JTACMonthViewProtocols.swift
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

/// The JTAppleCalendarMonthViewDataSource protocol is adopted by an
/// object that mediates the application’s data model for a
/// the JTAppleCalendarMonthViewDataSource object. data source provides the
/// the calendar-view object with the information it needs to construct and
/// then modify it self
@available(*, unavailable, renamed: "JTACMonthViewDataSource")
public protocol JTAppleCalendarViewDataSource{}
public protocol JTACMonthViewDataSource: class {
    /// Asks the data source to return the start and end boundary dates
    /// as well as the calendar to use. You should properly configure
    /// your calendar at this point.
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    /// - returns:
    ///     - ConfigurationParameters instance:
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters
}

/// The delegate of a JTAppleCalendarMonthView object must adopt the
/// JTAppleCalendarMonthViewDelegate protocol Optional methods of the protocol
/// allow the delegate to manage selections, and configure the cells
@available(*, unavailable, renamed: "JTACMonthViewDelegate")
public protocol JTAppleCalendarViewDelegate: class {}
public protocol JTACMonthViewDelegate: class {
    /// Asks the delegate if selecting the date-cell with a specified date is
    /// allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool

    /// Asks the delegate if de-selecting the
    /// date-cell with a specified date is allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(_ calendar: JTACMonthView, shouldDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool

    /// Tells the delegate that a date-cell with a specified date was selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///             This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath)
    
    /// Tells the delegate that a date-cell
    /// with a specified date was de-selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///             This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath)
    
    /// Tells the delegate that the item at the specified index path was highlighted.
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTACMonthView, didHighlightDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath)
    
    /// Tells the delegate that the item at the specified index path was un-highlighted.
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTACMonthView, didUnhighlightDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath)

    /// Tells the delegate that the JTAppleCalendar view
    /// scrolled to a segment beginning and ending with a particular date
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - startDate: The date at the start of the segment.
    ///     - endDate: The date at the end of the segment.
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo)

    /// Tells the delegate that the JTAppleCalendar view
    /// will scroll to a segment beginning and ending with a particular date
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - startDate: The date at the start of the segment.
    ///     - endDate: The date at the end of the segment.
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo)
    
    /// Tells the delegate that the JTAppleCalendar is about to display
    /// a date-cell. This is the point of customization for your date cells
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the cell.
    ///     - cellState: The month the date-cell belongs to.
    ///     - indexPath: use this value when dequeing cells
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell

    /// Tells the delegate that the JTAppleCalendar is about to
    /// display a header. This is the point of customization for your headers
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the header.
    ///     - indexPath: use this value when dequeing cells
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView
    
    /// Informs the delegate that the user just lifted their finger from swiping the calendar
    func scrollDidEndDecelerating(for calendar: JTACMonthView)
    
    /// Tells the delegate that a scroll occured
    func calendarDidScroll(_ calendar: JTACMonthView)
    
    /// Called to retrieve the size to be used for the month headers
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize?
    
    /// Implement the function to configure calendar cells. The code that will go in here is the same
    /// that you will code for your cellForItem function. This function is only called to address
    /// inconsistencies in the visual appearance as stated by Apple: https://developer.apple.com/documentation/uikit/uicollectionview/1771771-prefetchingenabled
    /// a date-cell. This is the point of customization for your date cells
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - cell: The cell
    ///     - date: date attached to the cell
    ///     - cellState: The month the date-cell belongs to.
    ///     - indexPath: use this value when dequeing cells
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath)
    
    /// Called to retrieve the size to be used for decoration views
    func sizeOfDecorationView(indexPath: IndexPath) -> CGRect
}

/// Default delegate functions
public extension JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool { return true }
    func calendar(_ calendar: JTACMonthView, shouldDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool { return true }
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {}
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {}
    func calendar(_ calendar: JTACMonthView, didHighlightDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {}
    func calendar(_ calendar: JTACMonthView, didUnhighlightDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {}
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {}
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {}
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        assert(false, "You have implemted a header size function, but forgot to implement the `headerViewForDateRange` function")
        return JTACMonthReusableView()
    }
    func calendarDidScroll(_ calendar: JTACMonthView) {}
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? { return nil }
    func sizeOfDecorationView(indexPath: IndexPath) -> CGRect { return .zero }
    func scrollDidEndDecelerating(for calendar: JTACMonthView) {}
}
