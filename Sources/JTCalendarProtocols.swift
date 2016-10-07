//
//  JTCalendarProtocols.swift
//  Pods
//
//  Created by JayT on 2016-06-07.
//
//

/// Default delegate functions
public extension JTAppleCalendarViewDelegate {

    func calendar(_ calendar: JTAppleCalendarView,
                  canSelectDate date: Date,
                  cell: JTAppleDayCellView,
                  cellState: CellState) -> Bool {
        return true
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  canDeselectDate date: Date,
                  cell: JTAppleDayCellView,
                  cellState: CellState) -> Bool {
        return true
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  didSelectDate date: Date,
                  cell: JTAppleDayCellView?,
                  cellState: CellState) {}

    func calendar(_ calendar: JTAppleCalendarView,
                  didDeselectDate date: Date,
                  cell: JTAppleDayCellView?,
                  cellState: CellState) {}

    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentFor range: (start: Date, end: Date),
                  belongingTo month: Int, rows: Int) {}

    func calendar(_ calendar: JTAppleCalendarView,
                  willDisplayCell cell: JTAppleDayCellView,
                  date: Date, cellState: CellState) {}

    func calendar(_ calendar: JTAppleCalendarView,
                  willResetCell cell: JTAppleDayCellView) {}

    func calendar(_ calendar: JTAppleCalendarView,
                  willDisplaySectionHeader header: JTAppleHeaderView,
                  range: (start: Date, end: Date), identifier: String) {}

    func calendar(_ calendar: JTAppleCalendarView,
                  sectionHeaderIdentifierFor range: (start: Date, end: Date),
                  belongingTo month: Int) -> String {
        return ""
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  sectionHeaderSizeFor range: (start: Date, end: Date),
                  belongingTo month: Int) -> CGSize {
        return CGSize.zero
    }

}

/// The JTAppleCalendarViewDataSource protocol is adopted by an
/// The object that mediates the application’s data model for a
/// The JTAppleCalendarViewDataSource object. data source provides the
/// The calendar-view object with the information it needs to construct and
/// The modify it self
public protocol JTAppleCalendarViewDataSource: class {
    /// Asks the data source to return the start and end boundary dates
    /// as well as the calendar to use. You should properly configure
    /// your calendar at this point.
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    /// - returns:
    ///     - ConfigurationParameters instance:
    func configureCalendar(
        _ calendar: JTAppleCalendarView) -> ConfigurationParameters
}

/// The delegate of a JTAppleCalendarView object must adopt the              .
/// JTAppleCalendarViewDelegate protocol Optional methods of the protocol    .
/// allow the delegate to manage selections, and configure the cells         .
public protocol JTAppleCalendarViewDelegate: class {

    /// Asks the delegate if selecting the date-cell with a specified date is
    /// allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(_ calendar: JTAppleCalendarView,
                  canSelectDate date: Date,
                  cell: JTAppleDayCellView,
                  cellState: CellState) -> Bool

    /// Asks the delegate if de-selecting the
    /// date-cell with a specified date is allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(_ calendar: JTAppleCalendarView,
                  canDeselectDate date: Date,
                  cell: JTAppleDayCellView,
                  cellState: CellState) -> Bool

    /// Tells the delegate that a date-cell with a specified date was selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///             This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTAppleCalendarView,
                  didSelectDate date: Date,
                  cell: JTAppleDayCellView?,
                  cellState: CellState)
    /// Tells the delegate that a date-cell
    /// with a specified date was de-selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///             This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTAppleCalendarView,
                  didDeselectDate date: Date,
                  cell: JTAppleDayCellView?,
                  cellState: CellState)

    /// Tells the delegate that the JTAppleCalendar view
    /// scrolled to a segment beginning and ending with a particular date
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - startDate: The date at the start of the segment.
    ///     - endDate: The date at the end of the segment.
    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentFor range: (start: Date, end: Date),
                  belongingTo month: Int, rows: Int)

    /// Tells the delegate that the JTAppleCalendar is about to display
    /// a date-cell. This is the point of customization for your date cells
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - cell: The date-cell that is about to be displayed.
    ///     - date: The date attached to the cell.
    ///     - cellState: The month the date-cell belongs to.

    func calendar(_ calendar: JTAppleCalendarView,
                  willDisplayCell cell: JTAppleDayCellView,
                  date: Date, cellState: CellState)
    /// Tells the delegate that the JTAppleCalendar is about to reset
    /// a date-cell. Reset your cell here before being reused on screen.
    /// Make sure this function exits quicky.
    /// - Parameters:
    ///     - cell: The date-cell that is about to be reset.
    func calendar(_ calendar: JTAppleCalendarView,
                  willResetCell cell: JTAppleDayCellView)

    /// Implement this function to use headers in your project.
    /// Return your registered header for the date presented.
    /// - Parameters:
    ///     - date: Contains the startDate and endDate for the
    ///             header that is about to be displayed
    /// - Returns:
    ///   String: Provide the registered header you wish to show for this date
    func calendar(_ calendar: JTAppleCalendarView,
                  sectionHeaderIdentifierFor range: (start: Date, end: Date),
                  belongingTo month: Int) -> String

    /// Implement this function to use headers in your project.
    /// Return the size for the header you wish to present
    /// - Parameters:
    ///     - date: Contains the startDate and endDate for
    ///             the header that is about to be displayed
    /// - Returns:
    ///   CGSize: Provide the size for the header
    ///           you wish to show for this date

    func calendar(_ calendar: JTAppleCalendarView,
                  sectionHeaderSizeFor range: (start: Date, end: Date),
                  belongingTo month: Int) -> CGSize

    /// Tells the delegate that the JTAppleCalendar is about to
    /// display a header. This is the point of customization for your headers
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - header: The header view that is about to be displayed.
    ///     - date: The date attached to the header.
    ///     - identifier: The identifier you provided for the header
    func calendar(_ calendar: JTAppleCalendarView,
                  willDisplaySectionHeader header: JTAppleHeaderView,
                  range: (start: Date, end: Date), identifier: String)
}
