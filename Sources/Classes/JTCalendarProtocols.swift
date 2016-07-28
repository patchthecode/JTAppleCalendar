//
//  JTCalendarProtocols.swift
//  Pods
//
//  Created by Jeron Thomas on 2016-06-07.
//
//

enum JTAppleCalendarViewSource {
    case fromXib(String)
    case fromType(AnyClass)
    case fromClassName(String)
}

/// Default delegate functions
public extension JTAppleCalendarViewDelegate {
    func calendar(calendar : JTAppleCalendarView, canSelectDate date : NSDate, cell: JTAppleDayCellView, cellState: CellState)->Bool {return true}
    func calendar(calendar : JTAppleCalendarView, canDeselectDate date : NSDate, cell: JTAppleDayCellView, cellState: CellState)->Bool {return true}
    func calendar(calendar : JTAppleCalendarView, didSelectDate date : NSDate, cell: JTAppleDayCellView?, cellState: CellState) {}
    func calendar(calendar : JTAppleCalendarView, didDeselectDate date : NSDate, cell: JTAppleDayCellView?, cellState: CellState) {}
    func calendar(calendar : JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {}
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date:NSDate, cellState: CellState) {}
    func calendar(calendar : JTAppleCalendarView, isAboutToResetCell cell: JTAppleDayCellView){}
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplaySectionHeader header: JTAppleHeaderView, date: (startDate: NSDate, endDate: NSDate), identifier: String) {}
    func calendar(calendar : JTAppleCalendarView, sectionHeaderIdentifierForDate date: (startDate: NSDate, endDate: NSDate)) -> String? {return nil}
    func calendar(calendar : JTAppleCalendarView, sectionHeaderSizeForDate date: (startDate: NSDate, endDate: NSDate)) -> CGSize {return CGSizeZero}
}

/// The JTAppleCalendarViewDataSource protocol is adopted by an object that mediates the application’s data model for a JTAppleCalendarViewDataSource object. The data source provides the calendar-view object with the information it needs to construct and modify it self
public protocol JTAppleCalendarViewDataSource: class {
    /// Asks the data source to return the start and end boundary dates as well as the calendar to use. You should properly configure your calendar at this point.
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    /// - returns:
    ///     - startDate: The *start* boundary date for your calendarView.
    ///     - endDate: The *end* boundary date for your calendarView.
    ///     - numberOfRows: The number of rows to be displayed per month
    ///     - calendar: The *calendar* to be used by the calendarView.
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar)
}


/// The delegate of a JTAppleCalendarView object must adopt the JTAppleCalendarViewDelegate protocol.
/// Optional methods of the protocol allow the delegate to manage selections, and configure the cells.
public protocol JTAppleCalendarViewDelegate: class {
    /// Asks the delegate if selecting the date-cell with a specified date is allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(calendar : JTAppleCalendarView, canSelectDate date : NSDate, cell: JTAppleDayCellView, cellState: CellState) -> Bool
    /// Asks the delegate if de-selecting the date-cell with a specified date is allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(calendar : JTAppleCalendarView, canDeselectDate date : NSDate, cell: JTAppleDayCellView, cellState: CellState) -> Bool
    /// Tells the delegate that a date-cell with a specified date was selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point. This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(calendar : JTAppleCalendarView, didSelectDate date : NSDate, cell: JTAppleDayCellView?, cellState: CellState) -> Void
    /// Tells the delegate that a date-cell with a specified date was de-selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point. This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(calendar : JTAppleCalendarView, didDeselectDate date : NSDate, cell: JTAppleDayCellView?, cellState: CellState) -> Void
    /// Tells the delegate that the JTAppleCalendar view scrolled to a segment beginning and ending with a particular date
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - startDate: The date at the start of the segment.
    ///     - endDate: The date at the end of the segment.
    func calendar(calendar : JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) -> Void
    /// Tells the delegate that the JTAppleCalendar is about to display a date-cell. This is the point of customization for your date cells
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - cell: The date-cell that is about to be displayed.
    ///     - date: The date attached to the cell.
    ///     - cellState: The month the date-cell belongs to.
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date:NSDate, cellState: CellState) -> Void
    /// Tells the delegate that the JTAppleCalendar is about to reset a date-cell. Reset your cell here before being reused on screen. Make sure this function exits quicky.
    /// - Parameters:
    ///     - cell: The date-cell that is about to be reset.
    func calendar(calendar : JTAppleCalendarView, isAboutToResetCell cell: JTAppleDayCellView) -> Void
    /// Implement this function to use headers in your project. Return your registered header for the date presented.
    /// - Parameters:
    ///     - date: Contains the startDate and endDate for the header that is about to be displayed
    /// - Returns:
    ///   String: Provide the registered header you wish to show for this date
    func calendar(calendar : JTAppleCalendarView, sectionHeaderIdentifierForDate date: (startDate: NSDate, endDate: NSDate)) -> String?
    /// Implement this function to use headers in your project. Return the size for the header you wish to present
    /// - Parameters:
    ///     - date: Contains the startDate and endDate for the header that is about to be displayed
    /// - Returns:
    ///   CGSize: Provide the size for the header you wish to show for this date
    func calendar(calendar : JTAppleCalendarView, sectionHeaderSizeForDate date: (startDate: NSDate, endDate: NSDate)) -> CGSize
    /// Tells the delegate that the JTAppleCalendar is about to display a header. This is the point of customization for your headers
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - header: The header view that is about to be displayed.
    ///     - date: The date attached to the header.
    ///     - identifier: The identifier you provided for the header
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplaySectionHeader header: JTAppleHeaderView, date: (startDate: NSDate, endDate: NSDate), identifier: String) -> Void
}

protocol JTAppleCalendarLayoutProtocol: class {
    var itemSize: CGSize {get set}
    var headerReferenceSize: CGSize {get set}
    var scrollDirection: UICollectionViewScrollDirection {get set}
    var cellCache: [Int:[UICollectionViewLayoutAttributes]] {get set}
    var headerCache: [UICollectionViewLayoutAttributes] {get set}
    func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint
    func sectionFromRectOffset(offset: CGPoint)-> Int
    func sizeOfContentForSection(section: Int)-> CGFloat
    func clearCache()
}

protocol JTAppleCalendarDelegateProtocol: class {
    var itemSize: CGFloat? {get set}
    var registeredHeaderViews: [JTAppleCalendarViewSource] {get set}
    func numberOfRows() -> Int
    func numberOfColumns() -> Int
    func numberOfsectionsPermonth() -> Int
    func numberOfMonthsInCalendar() -> Int
    func numberOfDaysPerSection() -> Int
    func referenceSizeForHeaderInSection(section: Int) -> CGSize
}


internal protocol JTAppleReusableViewProtocolTrait: class {
    associatedtype ViewType: UIView
    func setupView(cellSource: JTAppleCalendarViewSource)
    var view: ViewType? {get set}
}

extension JTAppleReusableViewProtocolTrait {
    func setupView(cellSource: JTAppleCalendarViewSource) {
        if view != nil { return}
        switch cellSource {
        case let .fromXib(xibName):
            let viewObject = NSBundle.mainBundle().loadNibNamed(xibName, owner: self, options: [:])
            guard let view = viewObject?[0] as? ViewType else {
                print("xib file class does not conform to the JTAppleViewProtocol")
                assert(false)
                return
            }
            self.view = view
            break
        case let .fromClassName(className):
            guard let theCellClass = NSBundle.mainBundle().classNamed(className) as? ViewType.Type else {
                print("Error loading registered class: '\(className)'")
                print("Make sure that: \n\n(1) It is a subclass of: 'UIView' and conforms to 'JTAppleViewProtocol' \n(2) You registered your class using the fully qualified name like so -->  'theNameOfYourProject.theNameOfYourClass'\n")
                assert(false)
                return
            }
            self.view = theCellClass.init()
            break
        case let .fromType(cellType):
            guard let theCellClass = cellType as? ViewType.Type else {
                print("Error loading registered class: '\(cellType)'")
                print("Make sure that: \n\n(1) It is a subclass of: 'UIiew' and conforms to 'JTAppleViewProtocol'\n")
                assert(false)
                return
            }
            self.view = theCellClass.init()
            break
        }
        (self as! UIView).addSubview(view!)
    }
}
