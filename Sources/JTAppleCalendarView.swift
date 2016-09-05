//
//  JTAppleCalendarView.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

let cellReuseIdentifier = "JTDayCell"

let NUMBER_OF_DAYS_IN_WEEK = 7

let MAX_NUMBER_OF_DAYS_IN_WEEK = 7                              // Should not be changed
let MIN_NUMBER_OF_DAYS_IN_WEEK = MAX_NUMBER_OF_DAYS_IN_WEEK     // Should not be changed
let MAX_NUMBER_OF_ROWS_PER_MONTH = 6                            // Should not be changed
let MIN_NUMBER_OF_ROWS_PER_MONTH = 1                            // Should not be changed

let FIRST_DAY_INDEX = 0
let OFFSET_CALC = 2
let NUMBER_OF_DAYS_INDEX = 1
let DATE_SELECTED_INDEX = 2
let TOTAL_DAYS_IN_MONTH = 3
let DATE_BOUNDRY = 4

/// Describes which month the cell belongs to
/// - ThisMonth: Cell belongs to the current month
/// - PreviousMonthWithinBoundary: Cell belongs to the previous month. Previous month is included in the date boundary you have set in your delegate
/// - PreviousMonthOutsideBoundary: Cell belongs to the previous month. Previous month is not included in the date boundary you have set in your delegate
/// - FollowingMonthWithinBoundary: Cell belongs to the following month. Following month is included in the date boundary you have set in your delegate
/// - FollowingMonthOutsideBoundary: Cell belongs to the following month. Following month is not included in the date boundary you have set in your delegate
///
/// You can use these cell states to configure how you want your date cells to look. Eg. you can have the colors belonging to the month be in color black, while the colors of previous months be in color gray.
public struct CellState {
    /// Describes which month owns the date
    public enum DateOwner: Int {
        /// Describes which month owns the date
        case thisMonth = 0, previousMonthWithinBoundary, previousMonthOutsideBoundary, followingMonthWithinBoundary, followingMonthOutsideBoundary
    }
    /// returns true if a cell is selected
    public let isSelected: Bool
    /// returns the date as a string
    public let text: String
    /// returns the a description of which month owns the date
    public let dateBelongsTo: DateOwner
    /// returns the date
    public let date: Date
    /// returns the day
    public let day: DaysOfWeek
    /// returns the row in which the date cell appears visually
    public let row: ()->Int
    /// returns the column in which the date cell appears visually
    public let column: ()->Int
    /// returns the section the date cell belongs to
    public let dateSection: ()->(dateRange:(start: Date, end: Date), month: Int)
    /// returns the position of a selection in the event you wish to do range selection
    public let selectedPosition: ()->SelectionRangePosition
    /// returns the cell frame. Useful if you wish to display something at the cell's frame/position
    public var cell: ()->JTAppleDayCell?
}

/// Selection position of a range-selected date cell
public enum SelectionRangePosition: Int {
    /// Selection position
    case left = 1, middle, right, full, none
}

/// Days of the week. By setting you calandar's first day of week, you can change which day is the first for the week. Sunday is by default.
public enum DaysOfWeek: Int {
    /// Days of the week.
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

/// An instance of JTAppleCalendarView (or simply, a calendar view) is a means for displaying and interacting with a gridstyle layout of date-cells
open class JTAppleCalendarView: UIView {
    /// Configures the size of your date cells
    public var itemSize: CGFloat?
    
    /// Enables and disables animations when scrolling to and from date-cells
    public var animationsEnabled = true
    /// The scroll direction of the sections in JTAppleCalendar.
    public var direction : UICollectionViewScrollDirection = .horizontal {
        didSet {
            if oldValue == direction { return }
            let layout = generateNewLayout()
            calendarView.collectionViewLayout = layout
        }
    }
    /// Enables/Disables multiple selection on JTAppleCalendar
    public var allowsMultipleSelection: Bool = false {
        didSet {
            self.calendarView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    /// First day of the week value for JTApleCalendar. You can set this to anyday. After changing this value you must reload your calendar view to show the change.
    public var firstDayOfWeek = DaysOfWeek.sunday {
        didSet {
            if firstDayOfWeek != oldValue { layoutNeedsUpdating = true }
        }
    }
    
    /// Alerts the calendar that range selection will be checked. If you are not using rangeSelection and you enable this, then whenever you click on a datecell, you may notice a very fast refreshing of the date-cells both left and right of the cell you just selected.
    public var rangeSelectionWillBeUsed = false
    
    var lastSavedContentOffset: CGFloat = 0.0
    var triggerScrollToDateDelegate: Bool? = true
    
    
    
    
    // Keeps track of item size for a section. This is an optimization
    var scrollInProgress = false
    private var layoutNeedsUpdating = false
    
    /// The object that acts as the data source of the calendar view.
    weak public var dataSource : JTAppleCalendarViewDataSource? {
        didSet {
            monthInfo = setupMonthInfoDataForStartAndEndDate()
            updateLayoutItemSize(calendarView.collectionViewLayout as! JTAppleCalendarLayout)
            reloadData(checkDelegateDataSource: false)
        }
    }
    /// The object that acts as the delegate of the calendar view.
    weak public var delegate: JTAppleCalendarViewDelegate?

    var dateComponents = DateComponents()
    var delayedExecutionClosure: [(()->Void)] = []
    
    #if os(iOS)
        var lastOrientation: UIInterfaceOrientation?
    #endif
    
    var currentSectionPage: Int {
        return (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).sectionFromRectOffset(calendarView.contentOffset)
    }
  
    var startDateCache: Date {
        get { return cachedConfiguration.startDate }
    }
    
    var endDateCache: Date {
        get { return cachedConfiguration.endDate }
    }
    
    var calendar: Calendar {
        get { return cachedConfiguration.calendar }
    }
    
    lazy var cachedConfiguration: (startDate: Date, endDate: Date, numberOfRows: Int, calendar: Calendar) = {
        [weak self] in
        
        guard let  config = self!.dataSource?.configureCalendar(self!) else {
            assert(false, "DataSource is not set")
            return (startDate: Date(), endDate: Date(), 0, Calendar(identifier: .gregorian))
        }
        
        return (startDate: config.startDate, endDate: config.endDate, numberOfRows: config.numberOfRows, calendar: config.calendar)
        }()
    
    // Set the start of the month
    lazy var startOfMonthCache: Date = {
        [weak self] in
        if let startDate = Date.startOfMonthForDate(self!.startDateCache, usingCalendar: self!.calendar) { return startDate }
        assert(false, "Error: StartDate was not correctly generated for start of month. current date was used: \(Date())")
        return Date()
        }()
    
    // Set the end of month
    lazy var endOfMonthCache: Date = {
        [weak self] in
        if let endDate = Date.endOfMonthForDate(self!.endDateCache, usingCalendar: self!.calendar) { return endDate }
        assert(false, "Error: Date was not correctly generated for end of month. current date was used: \(Date())")
        return Date()
        }()
    
    
    var theSelectedIndexPaths: [IndexPath] = []
    var theSelectedDates:      [Date]      = []
    
    /// Returns all selected dates
    public var selectedDates: [Date] {
        get {
            // Array may contain duplicate dates in case where out-dates are selected. So clean it up here
            return Array(Set(theSelectedDates)).sorted()
        }
    }
    
    lazy var monthInfo : [[Int]] = {
        [weak self] in
        let newMonthInfo = self!.setupMonthInfoDataForStartAndEndDate()
        return newMonthInfo
        }()
    
    var numberOfMonths: Int = 0
    var numberOfSectionsPerMonth: Int = 0
    var numberOfItemsPerSection: Int {return MAX_NUMBER_OF_DAYS_IN_WEEK * cachedConfiguration.numberOfRows}
    
    /// Cell inset padding for the x and y axis of every date-cell on the calendar view.
    public var cellInset: CGPoint = CGPoint(x: 3, y: 3)
    var cellViewSource: JTAppleCalendarViewSource!
    var registeredHeaderViews: [JTAppleCalendarViewSource] = []
    
    /// Enable or disable swipe scrolling of the calendar with this variable
    public var scrollEnabled: Bool = true {
        didSet { calendarView.isScrollEnabled = scrollEnabled }
    }
    
    // Configure the scrolling behavior
    public var scrollingMode: ScrollingMode = .stopAtEachCalendarFrameWidth {
        didSet {
            switch scrollingMode {
            case .stopAtEachCalendarFrameWidth:
                calendarView.decelerationRate = UIScrollViewDecelerationRateFast
            case .stopAtEach,.stopAtEachSection:
                calendarView.decelerationRate = UIScrollViewDecelerationRateFast
            case .nonStopToSection, .nonStopToCell, .nonStopTo, .none:
                calendarView.decelerationRate = UIScrollViewDecelerationRateNormal
            }
            
            #if os(iOS)
                switch scrollingMode {
                case .stopAtEachCalendarFrameWidth:
                    calendarView.isPagingEnabled = true
                default:
                    calendarView.isPagingEnabled = false
                }
            #endif
        }
    }
    
    lazy var calendarView : UICollectionView = {
        
        let layout = JTAppleCalendarLayout(withDelegate: self)
        layout.scrollDirection = self.direction
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.decelerationRate = UIScrollViewDecelerationRateFast
        cv.backgroundColor = UIColor.clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.allowsMultipleSelection = false
        #if os(iOS)
            cv.isPagingEnabled = true
        #endif
        
        return cv
    }()
    
    private func updateLayoutItemSize (_ layout: JTAppleCalendarLayoutProtocol) {
        if dataSource == nil { return } // If the delegate is not set yet, then return
        // Default Item height
        var height: CGFloat = (self.calendarView.bounds.size.height - layout.headerReferenceSize.height) / CGFloat(cachedConfiguration.numberOfRows)
        // Default Item width
        var width: CGFloat = self.calendarView.bounds.size.width / CGFloat(MAX_NUMBER_OF_DAYS_IN_WEEK)

        if let userSetItemSize = self.itemSize {
            if direction == .vertical { height = userSetItemSize }
            if direction == .horizontal { width = userSetItemSize }
        }

        layout.itemSize = CGSize(width: width, height: height)
    }
    
    /// The frame rectangle which defines the view's location and size in its superview coordinate system.
    override open var frame: CGRect {
        didSet {
            calendarView.frame = CGRect(x:0.0, y:/*bufferTop*/0.0, width: self.frame.size.width, height:self.frame.size.height/* - bufferBottom*/)
            #if os(iOS)
                let orientation = UIApplication.shared.statusBarOrientation
                if orientation == .unknown { return }
                if lastOrientation != orientation {
                    calendarView.collectionViewLayout.invalidateLayout()
                    let layout = calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol
                    layout.clearCache()   
                    lastOrientation = orientation
                    updateLayoutItemSize(self.calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol)
                    if delegate != nil { reloadData() }
                } else {
                    updateLayoutItemSize(self.calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol)
                }
            #elseif os(tvOS)
                calendarView.collectionViewLayout.invalidateLayout()
                let layout = calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol
                layout.clearCache()
                updateLayoutItemSize(self.calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol)
                if delegate != nil { reloadData() }
                updateLayoutItemSize(self.calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol)
            #endif
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    
    
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    override open func awakeFromNib() { self.initialSetup() }
    
    /// Lays out subviews.
    override open func layoutSubviews() { self.frame = super.frame }
    
    // MARK: Setup
    func initialSetup() {
        self.clipsToBounds = true
        self.calendarView.register(JTAppleDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        self.addSubview(self.calendarView)
    }
    
    func restoreSelectionStateForCellAtIndexPath(_ indexPath: IndexPath) {
        if theSelectedIndexPaths.contains(indexPath) {
            calendarView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
    }
    
    func dateFromSection(_ section: Int) -> (dateRange:(start: Date, end: Date), month: Int)? {
        if !monthInfo.indices.contains(section) {return nil}
        let monthData = monthInfo[section]
        let itemLength = monthData[NUMBER_OF_DAYS_INDEX] == 0 ? 7 : monthData[NUMBER_OF_DAYS_INDEX]
        let fdIndex = monthData[FIRST_DAY_INDEX]
        let startIndex = IndexPath(item: fdIndex, section: section)
        let endIndex = IndexPath(item: fdIndex + itemLength - 1, section: section)
        if let theDate = calendar.date(byAdding: .month, value: section / (numberOfSectionsPerMonth), to: cachedConfiguration.startDate) {
            let monthNumber = calendar.dateComponents([.month], from: theDate)
            if
                let theStartDate = dateFromPath(startIndex),
                let theEndDate = dateFromPath(endIndex) { return ((theStartDate, theEndDate), monthNumber.month!) }
        }
        return nil
    }
    
    func validForwardAndBackwordSelectedIndexes(forIndexPath indexPath: IndexPath)->[IndexPath] {
        var retval = [IndexPath]()
        if let validForwardIndex = calendarView.layoutAttributesForItem(at: IndexPath(item: indexPath.item + 1, section: indexPath.section)),
            theSelectedIndexPaths.contains(validForwardIndex.indexPath){
            retval.append(validForwardIndex.indexPath)
        }
        
        if let validBackwardIndex = calendarView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: indexPath.item - 1, section: indexPath.section)),
            theSelectedIndexPaths.contains(validBackwardIndex.indexPath) {
            retval.append(validBackwardIndex.indexPath)
        }
        return retval
    }
    
    func calendarOffsetIsAlreadyAtScrollPosition(forIndexPath indexPath:IndexPath) -> Bool? {
        var retval: Bool?
        
        // If the scroll is set to animate, and the target content offset is already on the screen, then the didFinishScrollingAnimation
        // delegate will not get called. Once animation is on let's force a scroll so the delegate MUST get caalled
        if let attributes = self.calendarView.layoutAttributesForItem(at: indexPath) {
            let layoutOffset: CGFloat
            let calendarOffset: CGFloat
            if direction == .horizontal {
                layoutOffset = attributes.frame.origin.x
                calendarOffset = calendarView.contentOffset.x
            } else {
                layoutOffset = attributes.frame.origin.y
                calendarOffset = calendarView.contentOffset.y
            }
            if  calendarOffset == layoutOffset || (scrollingMode.pagingIsEnabled() && (indexPath.section ==  currentSectionPage)) {
                retval = false
            }
        }
        return retval
    }
    
    func calendarOffsetIsAlreadyAtScrollPosition(forOffset offset:CGPoint) -> Bool? {
        var retval: Bool?
        
        // If the scroll is set to animate, and the target content offset is already on the screen, then the didFinishScrollingAnimation
        // delegate will not get called. Once animation is on let's force a scroll so the delegate MUST get caalled
        
        let theOffset = direction == .horizontal ? offset.x : offset.y
        let divValue = direction == .horizontal ? calendarView.frame.width : calendarView.frame.height
        let sectionForOffset = Int(theOffset / divValue)
        let calendarCurrentOffset = direction == .horizontal ? calendarView.contentOffset.x : calendarView.contentOffset.y
        if
            calendarCurrentOffset == theOffset ||
                (scrollingMode.pagingIsEnabled() && (sectionForOffset ==  currentSectionPage)){
            retval = true
        } else {
            retval = false
        }
        return retval
    }
    
    func scrollToHeaderInSection(_ section:Int, triggerScrollToDateDelegate: Bool = false, withAnimation animation: Bool = true, completionHandler: (()->Void)? = nil)  {
        if registeredHeaderViews.count < 1 { return }
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        let indexPath = IndexPath(item: 0, section: section)
        delayRunOnMainThread(0.0) {
            if let attributes =  self.calendarView.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: indexPath) {
                if let validHandler = completionHandler {
                    self.delayedExecutionClosure.append(validHandler)
                }
                
                let topOfHeader = CGPoint(x: attributes.frame.origin.x, y: attributes.frame.origin.y)
                self.scrollInProgress = true
                
                self.calendarView.setContentOffset(topOfHeader, animated:animation)
                if  !animation {
                    self.scrollViewDidEndScrollingAnimation(self.calendarView)
                    self.scrollInProgress = false
                } else {
                    // If the scroll is set to animate, and the target content offset is already on the screen, then the didFinishScrollingAnimation
                    // delegate will not get called. Once animation is on let's force a scroll so the delegate MUST get caalled
                    if let check = self.calendarOffsetIsAlreadyAtScrollPosition(forOffset: topOfHeader), check == true {
                        self.scrollViewDidEndScrollingAnimation(self.calendarView)
                        self.scrollInProgress = false
                    }
                }
            }
        }
    }
        
    func reloadData(checkDelegateDataSource check: Bool, withAnchorDate anchorDate: Date? = nil, withAnimation animation: Bool = false, completionHandler:(()->Void)? = nil) {
        // Reload the datasource
        if check { reloadDelegateDataSource() }
        var layoutWasUpdated: Bool?
        if layoutNeedsUpdating {
            self.configureChangeOfRows()
            self.layoutNeedsUpdating = false
            layoutWasUpdated = true
        }
        // Reload the data
        self.calendarView.reloadData()
        
        // Restore the selected index paths
        for indexPath in theSelectedIndexPaths { restoreSelectionStateForCellAtIndexPath(indexPath) }
        
        delayRunOnMainThread(0.0) {
            let scrollToDate = {(date: Date) -> Void in
                if self.registeredHeaderViews.count < 1 {
                    self.scrollToDate(date, triggerScrollToDateDelegate: false, animateScroll: animation, completionHandler: completionHandler)
                } else {
                    self.scrollToHeaderForDate(date, triggerScrollToDateDelegate: false, withAnimation: animation, completionHandler: completionHandler)
                }
            }
            if let validAnchorDate = anchorDate { // If we have a valid anchor date, this means we want to scroll
                // This scroll should happen after the reload above
                scrollToDate(validAnchorDate)
            } else {
                if layoutWasUpdated == true {
                    // This is a scroll done after a layout reset and dev didnt set an anchor date. If a scroll is in progress, then cancel this one and
                    // allow it to take precedent
                    if !self.scrollInProgress {
                        scrollToDate(self.startOfMonthCache)
                    } else {
                        if let validCompletionHandler = completionHandler { self.delayedExecutionClosure.append(validCompletionHandler) }
                    }
                } else {
                    if let validCompletionHandler = completionHandler {
                        if self.scrollInProgress {
                            self.delayedExecutionClosure.append(validCompletionHandler)
                        } else {
                            validCompletionHandler()
                        }
                    }
                }
            }
        }
    }
    
    func executeDelayedTasks() {
        let tasksToExecute = delayedExecutionClosure
        for aTaskToExecute in tasksToExecute { aTaskToExecute() }
        delayedExecutionClosure.removeAll()
    }
    
    private func reloadDelegateDataSource() {
        if let
            newDateBoundary = dataSource?.configureCalendar(self) {
            // Jt101 do a check in each var to see if user has bad star/end dates
            let newStartOfMonth = Date.startOfMonthForDate(newDateBoundary.startDate, usingCalendar: cachedConfiguration.calendar)
            let newEndOfMonth = Date.endOfMonthForDate(newDateBoundary.startDate, usingCalendar: cachedConfiguration.calendar)
            let oldStartOfMonth = Date.startOfMonthForDate(cachedConfiguration.startDate, usingCalendar: cachedConfiguration.calendar)
            let oldEndOfMonth = Date.endOfMonthForDate(cachedConfiguration.startDate, usingCalendar: cachedConfiguration.calendar)
            
            if
                newStartOfMonth != oldStartOfMonth ||
                newEndOfMonth != oldEndOfMonth ||
                newDateBoundary.calendar != cachedConfiguration.calendar ||
                newDateBoundary.numberOfRows != cachedConfiguration.numberOfRows {
                    layoutNeedsUpdating = true
            }
        }
    }
    
    func configureChangeOfRows() {
        let layout = calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol
        layout.clearCache()
        monthInfo = setupMonthInfoDataForStartAndEndDate()
        
        // the selected dates and paths will be retained. Ones that are not available on the new layout will be removed.
        var indexPathsToReselect = [IndexPath]()
        var newDates = [Date]()
        for date in selectedDates {
            // add the index paths of the new layout
            let path = pathsFromDates([date])
            indexPathsToReselect.append(contentsOf: path)
            
            if
                path.count > 0,
                let possibleCounterPartDateIndex = indexPathOfdateCellCounterPart(date, indexPath: path[0], dateOwner: CellState.DateOwner.thisMonth) {
                indexPathsToReselect.append(possibleCounterPartDateIndex)
            }
        }
        
        for path in indexPathsToReselect {
            if let date = dateFromPath(path) { newDates.append(date) }
        }
        
        theSelectedDates = newDates
        theSelectedIndexPaths = indexPathsToReselect
    }
    
    func calendarViewHeaderSizeForSection(_ section: Int) -> CGSize {
        var retval = CGSize.zero
        if registeredHeaderViews.count > 0 {
            if
                let validDate = dateFromSection(section),
                let size = delegate?.calendar(self, sectionHeaderSizeForDate:validDate.dateRange, belongingTo: validDate.month){retval = size }
        }
        return retval
    }
    
    func indexPathOfdateCellCounterPart(_ date: Date, indexPath: IndexPath, dateOwner: CellState.DateOwner) -> IndexPath? {
        var retval: IndexPath?
        if dateOwner != .thisMonth { // If the cell is anything but this month, then the cell belongs to either a previous of following month
            // Get the indexPath of the counterpartCell
            let counterPathIndex = pathsFromDates([date])
            if counterPathIndex.count > 0 {
                retval = counterPathIndex[0]
            }
        } else { // If the date does belong to this month, then lets find out if it has a counterpart date
            if date >= startOfMonthCache && date <= endOfMonthCache {
                let dayIndex = calendar.dateComponents([.day], from: date).day!
                if case 1...13 = dayIndex  { // then check the previous month
                    // get the index path of the last day of the previous month
                    
                    guard let prevMonth = calendar.date(byAdding: .month, value: -1, to: date),
                        prevMonth >= startOfMonthCache && prevMonth <= endOfMonthCache else {
                        return retval
                    }
                    
                    guard let lastDayOfPrevMonth = Date.endOfMonthForDate(prevMonth, usingCalendar: calendar) else {
                        print("Error generating date in indexPathOfdateCellCounterPart(). Contact the developer on github")
                        return retval
                    }
                    let indexPathOfLastDayOfPreviousMonth = pathsFromDates([lastDayOfPrevMonth])
                    
                    if indexPathOfLastDayOfPreviousMonth.count > 0 {
                        let LastDayIndexPath = indexPathOfLastDayOfPreviousMonth[0]
                        
                        var section = (LastDayIndexPath as NSIndexPath).section
                        var itemIndex = (LastDayIndexPath as NSIndexPath).item + dayIndex
                        
                        // Determine if the sections/item needs to be adjusted
                        let extraSection = itemIndex / numberOfItemsPerSection
                        let extraIndex = itemIndex % numberOfItemsPerSection
                        
                        section += extraSection
                        itemIndex = extraIndex
                        
                        let reCalcRapth = IndexPath(item: itemIndex, section: section)
                        
                        // We are going to call a layout attribute function. Make sure the layout is updated. The layout/cell cache will be empty if there was a layout change
                        if (calendarView.collectionViewLayout as! JTAppleCalendarLayout).cellCache.count < 1 {
                            self.calendarView.collectionViewLayout.prepare()
                        }
                        if let attrib = calendarView.collectionViewLayout.layoutAttributesForItem(at: reCalcRapth) {
                            if dateFromPath(attrib.indexPath) == date { retval = attrib.indexPath }
                        }
                    } else {
                        print("out of range error in indexPathOfdateCellCounterPart() upper. This should not happen. Contact developer on github")
                    }
                } else if case 26...31 = dayIndex  { // check the following month
                    guard let followingMonth = calendar.date(byAdding: .month, value: 1, to: date), followingMonth >= startOfMonthCache && followingMonth <= endOfMonthCache else {
                        return retval
                    }
                    
                    guard let firstDayOfFollowingMonth = Date.startOfMonthForDate(followingMonth, usingCalendar: calendar) else {
                        print("Error generating date in indexPathOfdateCellCounterPart(). Contact the developer on github")
                        return retval
                    }
                    let indexPathOfFirstDayOfFollowingMonth = pathsFromDates([firstDayOfFollowingMonth])
                    if indexPathOfFirstDayOfFollowingMonth.count > 0 {
                        let firstDayIndex = (indexPathOfFirstDayOfFollowingMonth[0] as NSIndexPath).item
                        let lastDay = Date.endOfMonthForDate(date, usingCalendar: calendar)!
                        let lastDayIndex = calendar.dateComponents([.day], from: lastDay).day
                        let x = lastDayIndex! - dayIndex
                        let y = firstDayIndex - x - 1
                        
                        if y > -1 {
                            return IndexPath(item: y, section: (indexPathOfFirstDayOfFollowingMonth[0] as NSIndexPath).section)
                        }
                    } else {
                        print("out of range error in indexPathOfdateCellCounterPart() lower. This should not happen. Contact developer on github")
                    }
                }
            }
        }
        return retval
    }
    
    func scrollToSection(_ section: Int, triggerScrollToDateDelegate: Bool = false, animateScroll: Bool = true, completionHandler: (()->Void)?) {
        if scrollInProgress { return }
        if let date = dateFromPath(IndexPath(item: MAX_NUMBER_OF_DAYS_IN_WEEK - 1, section:section)) {
            let recalcDate = Date.startOfMonthForDate(date, usingCalendar: calendar)!
            self.scrollToDate(recalcDate, triggerScrollToDateDelegate: triggerScrollToDateDelegate, animateScroll: animateScroll, preferredScrollPosition: nil, completionHandler: completionHandler)
        }
    }
    
    func generateNewLayout() -> UICollectionViewLayout {
        let layout: UICollectionViewLayout = JTAppleCalendarLayout(withDelegate: self)
        let conformingProtocolLayout = layout as! JTAppleCalendarLayoutProtocol
        
        conformingProtocolLayout.scrollDirection = direction
        return layout
    }
    
    func setupMonthInfoDataForStartAndEndDate()-> [[Int]] {
        var retval: [[Int]] = []
        if var validConfig = dataSource?.configureCalendar(self) {
            // check if the dates are in correct order
            if validConfig.calendar.compare(validConfig.startDate, to: validConfig.endDate, toGranularity: .nanosecond) == ComparisonResult.orderedDescending {
                assert(false, "Error, your start date cannot be greater than your end date\n")
                return retval
            }
            
            // Check to see if we have a valid number of rows
            switch validConfig.numberOfRows {
            case 1, 2, 3:
                break
            default:
                validConfig.numberOfRows = 6
            }
            
            // Set the new cache
            cachedConfiguration = validConfig
            
            if
                let startMonth = Date.startOfMonthForDate(validConfig.startDate, usingCalendar: validConfig.calendar),
                let endMonth = Date.endOfMonthForDate(validConfig.endDate, usingCalendar: validConfig.calendar) {
                
                startOfMonthCache = startMonth
                endOfMonthCache = endMonth
                
                let differenceComponents = validConfig.calendar.dateComponents( [.month], from: startOfMonthCache, to: endOfMonthCache )
                
                // Create boundary date
                let leftDate = validConfig.calendar.date(byAdding: .weekday, value: -1, to: startOfMonthCache)!
                let leftDateInt = validConfig.calendar.component(.day, from: leftDate)
                
                // Number of months
                numberOfMonths = differenceComponents.month! + 1 // if we are for example on the same month and the difference is 0 we still need 1 to display it
                
                // Number of sections in each month
                numberOfSectionsPerMonth = Int(ceil(Float(MAX_NUMBER_OF_ROWS_PER_MONTH)  / Float(cachedConfiguration.numberOfRows)))

                // Section represents # of months. section is used as an offset to determine which month to calculate
                for numberOfMonthsIndex in 0 ... numberOfMonths - 1 {
                    if let correctMonthForSectionDate = validConfig.calendar.date(byAdding: .month, value: numberOfMonthsIndex, to: startOfMonthCache) {
                        let numberOfDaysInMonth = validConfig.calendar.range(of: .day, in: .month, for: correctMonthForSectionDate)!.count
                        
                        var firstWeekdayOfMonthIndex = validConfig.calendar.component(.weekday, from: correctMonthForSectionDate)
                        firstWeekdayOfMonthIndex -= 1 // firstWeekdayOfMonthIndex should be 0-Indexed
                        

                        var firstDayCalValue = 0
                        switch firstDayOfWeek {
                            case .monday: firstDayCalValue = 6 case .tuesday: firstDayCalValue = 5 case .wednesday: firstDayCalValue = 4
                            case .thursday: firstDayCalValue = 10 case .friday: firstDayCalValue = 9
                            case .saturday: firstDayCalValue = 8 default: firstDayCalValue = 7
                        }
                        
                        firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex + firstDayCalValue) % 7 // push it modularly so that we take it back one day so that the first day is Monday instead of Sunday which is the default
                        
                        
                        // We have number of days in month, now lets see how these days will be allotted into the number of sections in the month
                        // We will add the first segment manually to handle the fdIndex inset
                        let aFullSection = (cachedConfiguration.numberOfRows * MAX_NUMBER_OF_DAYS_IN_WEEK)
                        var numberOfDaysInFirstSection = aFullSection - firstWeekdayOfMonthIndex
                        
                        // If the number of days in first section is greater that the days of the month, then use days of month instead
                        if numberOfDaysInFirstSection > numberOfDaysInMonth {
                            numberOfDaysInFirstSection = numberOfDaysInMonth
                        }
                        
                        let firstSectionDetail: [Int] = [firstWeekdayOfMonthIndex, numberOfDaysInFirstSection, 0, numberOfDaysInMonth] //fdIndex, numberofDaysInMonth, offset
                        retval.append(firstSectionDetail)
                        let numberOfSectionsLeft = numberOfSectionsPerMonth - 1
                        
                        // Continue adding other segment details in loop
                        if numberOfSectionsLeft < 1 {continue} // Continue if there are no more sections
                        
                        var numberOfDaysLeft = numberOfDaysInMonth - numberOfDaysInFirstSection
                        for _ in 0 ... numberOfSectionsLeft - 1 {
                            switch numberOfDaysLeft {
                            case _ where numberOfDaysLeft <= aFullSection: // Partial rows
                                let midSectionDetail: [Int] = [0, numberOfDaysLeft, firstWeekdayOfMonthIndex]
                                retval.append(midSectionDetail)
                                numberOfDaysLeft = 0
                            case _ where numberOfDaysLeft > aFullSection: // Full Rows
                                let lastPopulatedSectionDetail: [Int] = [0, aFullSection, firstWeekdayOfMonthIndex]
                                retval.append(lastPopulatedSectionDetail)
                                numberOfDaysLeft -= aFullSection
                            default:
                                break
                            }
                        }
                    }
                }
                retval[0].append(leftDateInt)
            }
        }
        return retval
    }
    
    func pathsFromDates(_ dates:[Date])-> [IndexPath] {
        var returnPaths: [IndexPath] = []
        for date in dates {
            if  calendar.startOfDay(for: date) >= startOfMonthCache && calendar.startOfDay(for: date) <= endOfMonthCache {
                let periodApart = calendar.dateComponents([.month], from: startOfMonthCache, to: date)
                let monthSectionIndex = periodApart.month!
                let startSectionIndex = monthSectionIndex * numberOfSectionsPerMonth
                let sectionIndex = startMonthSectionForSection(startSectionIndex) // Get the section within the month
                
                // Get the section Information
                let currentMonthInfo = monthInfo[sectionIndex]
                let dayIndex = calendar.dateComponents([.day], from: date).day!
                
                // Given the following, find the index Path
                let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
                let cellIndex = dayIndex + fdIndex - 1
                let updatedSection = cellIndex / numberOfItemsPerSection
                let adjustedSection = sectionIndex + updatedSection
                let adjustedCellIndex = cellIndex - (numberOfItemsPerSection * (cellIndex / numberOfItemsPerSection))
                returnPaths.append(IndexPath(item: adjustedCellIndex, section: adjustedSection))
            }
        }
        return returnPaths
    }
}

extension JTAppleCalendarView {
    func cellStateFromIndexPath(_ indexPath: IndexPath, withDate date: Date, cell: JTAppleDayCell? = nil)->CellState {
        let itemIndex = indexPath.item
        let itemSection = indexPath.section
        let currentMonthInfo = monthInfo[itemSection]
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let nDays = currentMonthInfo[NUMBER_OF_DAYS_INDEX]
        let componentDay = calendar.component(.day, from: date)
        let componentWeekDay = calendar.component(.weekday, from: date)
        let cellText = String(componentDay)
        let dateBelongsTo: CellState.DateOwner
        
        if itemIndex >= fdIndex && itemIndex < fdIndex + nDays {
            dateBelongsTo = .thisMonth
        } else if itemIndex < fdIndex  && itemSection - 1 > -1  { // Prior month is available
            dateBelongsTo = .previousMonthWithinBoundary
        } else if itemIndex >= fdIndex + nDays && itemSection + 1 < monthInfo.count { // Following months
            dateBelongsTo = .followingMonthWithinBoundary
        } else if itemIndex < fdIndex { // Pre from the start
            dateBelongsTo = .previousMonthOutsideBoundary
        } else { // Post from the end
            dateBelongsTo = .followingMonthOutsideBoundary
        }
        
        let dayOfWeek = DaysOfWeek(rawValue: componentWeekDay)!
        let rangePosition = {()->SelectionRangePosition in
            if self.theSelectedIndexPaths.contains(indexPath) {
                if self.selectedDates.count == 1 { return .full}
                let left = self.theSelectedIndexPaths.contains(IndexPath(item: indexPath.item - 1, section: indexPath.section))
                let right = self.theSelectedIndexPaths.contains(IndexPath(item: indexPath.item + 1, section: indexPath.section))
                if (left == right) {
                    if left == false { return .full } else { return .middle }
                } else {
                    if left == false { return .left } else { return .right }
                }
            }
            return .none
        }
        

        let cellState = CellState(
            isSelected: theSelectedIndexPaths.contains(indexPath),
            text: cellText,
            dateBelongsTo: dateBelongsTo,
            date: date,
            day: dayOfWeek,
            row: { return itemIndex / MAX_NUMBER_OF_DAYS_IN_WEEK },
            column: { return itemIndex % MAX_NUMBER_OF_DAYS_IN_WEEK },
            dateSection: { return self.dateFromSection(itemSection)! },
            selectedPosition: rangePosition,
            cell: {return cell}
        )
        return cellState
    }
    
    func startMonthSectionForSection(_ aSection: Int)->Int {
        let monthIndexWeAreOn = aSection / numberOfSectionsPerMonth
        let nextSection = numberOfSectionsPerMonth * monthIndexWeAreOn
        return nextSection
    }
    
    func batchReloadIndexPaths(_ indexPaths: [IndexPath]) {
        if indexPaths.count < 1 { return }
        UICollectionView.performWithoutAnimation({
            self.calendarView.performBatchUpdates({
                self.calendarView.reloadItems(at: indexPaths)
                }, completion: nil)  
        })
    }
    
    func addCellToSelectedSetIfUnselected(_ indexPath: IndexPath, date: Date) {
        if self.theSelectedIndexPaths.contains(indexPath) == false {
            self.theSelectedIndexPaths.append(indexPath)
            self.theSelectedDates.append(date)
        }
    }
    func deleteCellFromSelectedSetIfSelected(_ indexPath: IndexPath) {
        if let index = self.theSelectedIndexPaths.index(of: indexPath) {
            self.theSelectedIndexPaths.remove(at: index)
            self.theSelectedDates.remove(at: index)
        }
    }
    func deselectCounterPartCellIndexPath(_ indexPath: IndexPath, date: Date, dateOwner: CellState.DateOwner) -> IndexPath? {
        if let
            counterPartCellIndexPath = indexPathOfdateCellCounterPart(date, indexPath: indexPath, dateOwner: dateOwner) {
            deleteCellFromSelectedSetIfSelected(counterPartCellIndexPath)
            return counterPartCellIndexPath
        }
        return nil
    }
    
    func selectCounterPartCellIndexPathIfExists(_ indexPath: IndexPath, date: Date, dateOwner: CellState.DateOwner) -> IndexPath? {
        if let counterPartCellIndexPath = indexPathOfdateCellCounterPart(date, indexPath: indexPath, dateOwner: dateOwner) {
            let dateComps = calendar.dateComponents([.month, .day, .year], from: date)
            guard let counterpartDate = calendar.date(from: dateComps) else { return nil }
            addCellToSelectedSetIfUnselected(counterPartCellIndexPath, date:counterpartDate)
            return counterPartCellIndexPath
        }
        return nil
    }
    
    func dateFromPath(_ indexPath: IndexPath)-> Date? { // Returns nil if date is out of scope
        let itemIndex = indexPath.item
        let itemSection = indexPath.section
        let monthIndexWeAreOn = itemSection / numberOfSectionsPerMonth
        let currentMonthInfo = monthInfo[itemSection]
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let offSet = currentMonthInfo[OFFSET_CALC]
        let cellDate = (cachedConfiguration.numberOfRows * MAX_NUMBER_OF_DAYS_IN_WEEK * (itemSection % numberOfSectionsPerMonth)) + itemIndex - fdIndex - offSet + 1
        
        dateComponents.month = monthIndexWeAreOn
        dateComponents.weekday = cellDate - 1
        
        return calendar.date(byAdding: dateComponents, to: startOfMonthCache)
    }
}

extension JTAppleCalendarView: JTAppleCalendarDelegateProtocol {
    func numberOfRows() -> Int {return cachedConfiguration.numberOfRows}
    func numberOfColumns() -> Int { return MAX_NUMBER_OF_DAYS_IN_WEEK }
    func numberOfsectionsPermonth() -> Int { return numberOfSectionsPerMonth }
    func numberOfMonthsInCalendar() -> Int { return numberOfMonths }
    func numberOfDaysPerSection() -> Int { return numberOfItemsPerSection }
    
    func referenceSizeForHeaderInSection(_ section: Int) -> CGSize {
        if registeredHeaderViews.count < 1 { return CGSize.zero }
        return calendarViewHeaderSizeForSection(section)
    }
    
}
