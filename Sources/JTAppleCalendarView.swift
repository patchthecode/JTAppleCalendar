//
//  JTAppleCalendarView.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

let cellReuseIdentifier = "JTDayCell"


let maxNumberOfDaysInWeek = 7 // Should not be changed
let maxNumberOfRowsPerMonth = 6 // Should not be changed
let developerErrorMessage = "There was an error in this code section. " +
    "Please contact the developer on GitHub"

/// An instance of JTAppleCalendarView (or simply, a calendar view) is a
/// means for displaying and interacting with a gridstyle layout of date-cells
open class JTAppleCalendarView: UIView {

    let dateGenerator = JTAppleDateConfigGenerator()

    /// Configures the behavior of the scrolling mode of the calendar
    public enum ScrollingMode {
        /// stopAtEachCalendarFrameWidth - non-continuous scrolling that will stop at each frame width
        case stopAtEachCalendarFrameWidth
        /// stopAtEachSection - non-continuous scrolling that will stop at each section
        case stopAtEachSection
        /// stopAtEach - non-continuous scrolling that will stop at each custom interval
        case stopAtEach(customInterval: CGFloat)
        /// nonStopToSection - continuous scrolling that will stop at a section
        case nonStopToSection(withResistance: CGFloat)
        /// nonStopToCell - continuous scrolling that will stop at a cell
        case nonStopToCell(withResistance: CGFloat)
        /// nonStopTo - continuous scrolling that will stop at acustom interval
        case nonStopTo(customInterval: CGFloat, withResistance: CGFloat)
        /// none - continuous scrolling that will eventually stop at a point
        case none

        func pagingIsEnabled() -> Bool {
            switch self {
            case .stopAtEachCalendarFrameWidth: return true
            default: return false
            }
        }
    }

    /// Configures the size of your date cells
    open var itemSize: CGFloat? {
        didSet {
            lastSize = CGSize.zero
            updateLayoutItemSize()
            layoutNeedsUpdating = true
        }
    }

    
    
    @available(*, deprecated: 6.1.2, message: "use 'scrollDirection' instead")
    /// The scroll direction of the sections in JTAppleCalendar.
    open var direction: UICollectionViewScrollDirection {
        set { scrollDirection = direction }
        get { return scrollDirection }
    }
    
    /// The scroll direction of the sections in JTAppleCalendar.
    open var scrollDirection: UICollectionViewScrollDirection = .horizontal {
        didSet {
            if oldValue == scrollDirection { return }
            calendarViewLayout.scrollDirection = scrollDirection
            updateLayoutItemSize()
            layoutNeedsUpdating = true
        }
    }

    /// Enables/Disables the stretching of date cells. When enabled cells will stretch to fit the width of a month in case of a <= 5 row month.
    open var allowsDateCellStretching = true {
        didSet {
            layoutNeedsUpdating = true
        }
    }
    
    /// Enables/Disables multiple selection on JTAppleCalendar
    open var allowsMultipleSelection: Bool = false {
        didSet {
            calendarView.allowsMultipleSelection = allowsMultipleSelection
        }
    }

    /// Alerts the calendar that range selection will be checked. If you are
    /// not using rangeSelection and you enable this,
    /// then whenever you click on a datecell, you may notice a very fast
    /// refreshing of the date-cells both left and right of the cell you
    /// just selected.
    open var rangeSelectionWillBeUsed = false
    // Keeps track of item size for a section. This is an optimization
    var lastSavedContentOffset: CGFloat = 0.0
    var triggerScrollToDateDelegate: Bool? = true
    var scrollInProgress = false
    var calendarViewLayout: JTAppleCalendarLayout {
        get {
            guard let layout = calendarView.collectionViewLayout as? JTAppleCalendarLayout else {
                developerError(string: "Calendar layout is not of type JTAppleCalendarLayout.")
                return JTAppleCalendarLayout(withDelegate: self)
            }
            return layout
        }
    }

    var layoutNeedsUpdating = false

    /// The object that acts as the data source of the calendar view.
    weak open var dataSource: JTAppleCalendarViewDataSource? {
        didSet {
            // Refetch the data source for a data source change
            setupMonthInfoAndMap()
        }
    }

    func setupMonthInfoAndMap() {
        theData = setupMonthInfoDataForStartAndEndDate()
    }

    /// Lays out subviews.
    override open func layoutSubviews() {
        frame = super.frame
    }
    
    var lastIndexOffset: (IndexPath, UICollectionElementCategory)?
    
    /// Informs when change in orientation
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if ((self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass)
            || self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass) {
            if calendarIsAlreadyLoaded {
                setMinVisibleDate()
                layoutNeedsUpdating = true
                reloadData()
            }
        }
    }

    /// The frame rectangle which defines the view's location and size in
    /// its superview coordinate system.
    override open var frame: CGRect {
        didSet {
            if !initialSetupIsComplete { return }
            calendarView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            updateLayoutItemSize()
            if calendarViewLayout.itemSize != lastSize {
                lastSize = calendarViewLayout.itemSize
                if !calendarIsAlreadyLoaded, delegate != nil { // This will only be set once
                    calendarIsAlreadyLoaded = true
                    reloadData() {[unowned self] in
                        self.executeDelayedTasks()
                    }
                    return
                }
            }
        }
    }

    /// The object that acts as the delegate of the calendar view.
    weak open var delegate: JTAppleCalendarViewDelegate?

    var delayedExecutionClosure: [(() -> Void)] = []
    var lastSize = CGSize.zero
    var calendarIsAlreadyLoaded: Bool = false

    var startDateCache: Date {
        get { return cachedConfiguration.startDate }
    }

    var endDateCache: Date {
        get { return cachedConfiguration.endDate }
    }

    var calendar: Calendar {
        get { return cachedConfiguration.calendar }
    }
    // Configuration parameters from the dataSource
    var cachedConfiguration: ConfigurationParameters!
    // Set the start of the month
    var startOfMonthCache: Date!
    // Set the end of month
    var endOfMonthCache: Date!

    var theSelectedIndexPaths: [IndexPath] = []
    var theSelectedDates: [Date] = []

    /// Returns all selected dates
    open var selectedDates: [Date] {
        get {
            // Array may contain duplicate dates in case where out-dates
            // are selected. So clean it up here
            return Array(Set(theSelectedDates)).sorted()
        }
    }

    var theData: CalendarData!

    var monthInfo: [Month] {
        get { return theData.months }
        set { theData.months = monthInfo }
    }

    var monthMap: [Int: Int] {
        get { return theData.sectionToMonthMap }
        set { theData.sectionToMonthMap = monthMap }
    }

    var numberOfMonths: Int {
        get { return monthInfo.count }
    }

    var totalDays: Int {
        get { return theData.totalDays }
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        return collectionView(calendarView, numberOfItemsInSection: section)
    }

    /// Section spacing of the calendar view.
    open var sectionSpacing: CGFloat = 0
    
    /// Cell inset padding for the x and y axis
    /// of every date-cell on the calendar view.
    open var cellInset: CGPoint = CGPoint(x: 3, y: 3) {
        didSet {
            // to handle https://github.com/patchthecode/JTAppleCalendar/issues/26
            if cellInset.x == 0 { cellInset.x = -0.1 }
            if cellInset.y == 0 { cellInset.y = -0.1 }
        }
    }
    var cellViewSource: JTAppleCalendarViewSource!
    var registeredHeaderViews: [JTAppleCalendarViewSource] = []
    var thereAreHeaders: Bool {
        return !registeredHeaderViews.isEmpty
    }

    /// Enable or disable swipe scrolling of the calendar with this variable
    open var scrollEnabled: Bool = true {
        didSet {
            calendarView.isScrollEnabled = scrollEnabled
        }
    }

    /// Configure the scrolling behavior
    open var scrollingMode: ScrollingMode = .stopAtEachCalendarFrameWidth {
        didSet {
            switch scrollingMode {
            case .stopAtEachCalendarFrameWidth: calendarView.decelerationRate = UIScrollViewDecelerationRateFast
            case .stopAtEach, .stopAtEachSection: calendarView.decelerationRate = UIScrollViewDecelerationRateFast
            case .nonStopToSection, .nonStopToCell, .nonStopTo, .none: calendarView.decelerationRate = UIScrollViewDecelerationRateNormal
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

    var calendarView: CustomCollectionView!
    

    fileprivate func updateLayoutItemSize() {
        if dataSource == nil {
            return
        }
        // If the delegate is not set yet, then return, 
        // because delegate methods will be called on the layout
        let layout = calendarViewLayout

        // Invalidate the layout

        // Default Item height
        var height: CGFloat = (calendarView.bounds.size.height - layout.headerReferenceSize.height) / CGFloat(cachedConfiguration.numberOfRows)
        // Default Item width
        var width: CGFloat = calendarView.bounds.size.width / CGFloat(maxNumberOfDaysInWeek)

        if let userSetItemSize = itemSize {
            if scrollDirection == .vertical {
                height = userSetItemSize
            } else {
                width = userSetItemSize
            }
        }
        let size = CGSize(width: width, height: height)

        if lastSize != size {
            layoutNeedsUpdating = true
            layout.itemSize = size
        }
    }
    
    /// Changes the calendar's reading orientation
    /// from left-to-right or right-to-left
    /// Useful for ethnic calendars
    var orientation: ReadingOrientation = .leftToRight

    /// Initializes and returns a newly allocated
    /// view object with the specified frame rectangle.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    func developerError(string: String) {
        print(string)
        print(developerErrorMessage)
        assert(false)
    }

    /// Returns an object initialized from data in a given unarchiver.
    /// self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Prepares the receiver for service after it has been loaded
    /// from an Interface Builder archive, or nib file.
    override open func awakeFromNib() {
        initialSetup()
    }

    var initialSetupIsComplete = false
    
    // MARK: Setup
    func initialSetup() {
        clipsToBounds = true
        let cv = CustomCollectionView(frame: frame, collectionViewLayout: JTAppleCalendarLayout(withDelegate: self))
        calendarView = cv
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.decelerationRate = UIScrollViewDecelerationRateFast
        calendarView.backgroundColor = UIColor.clear
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.showsVerticalScrollIndicator = false
        calendarView.allowsMultipleSelection = false
        #if os(iOS)
            calendarView.isPagingEnabled = true
        #endif
    
        calendarView.register(JTAppleDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        addSubview(calendarView)
        initialSetupIsComplete = true
        let x = frame
        frame = x
    }

    func restoreSelectionStateForCellAtIndexPath(_ indexPath: IndexPath) {
        if theSelectedIndexPaths.contains(indexPath) {
            calendarView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
    }

    func validForwardAndBackwordSelectedIndexes(forIndexPath indexPath: IndexPath) -> [IndexPath] {
        var retval: [IndexPath] = []
        if let validForwardIndex = calendarViewLayout.indexPath(direction: .next, of: indexPath.section, item: indexPath.item),
            theSelectedIndexPaths.contains(validForwardIndex) {
            retval.append(validForwardIndex)
        }
        if
            let validBackwardIndex = calendarViewLayout.indexPath(direction: .previous, of: indexPath.section, item: indexPath.item),
            theSelectedIndexPaths.contains(validBackwardIndex) {
            retval.append(validBackwardIndex)
        }
        return retval
    }
    
    func scrollTo(indexPath: IndexPath, isAnimationEnabled: Bool, position: UICollectionViewScrollPosition, completionHandler: (() -> Void)?) {
        if let validCompletionHandler = completionHandler {
            delayedExecutionClosure.append(validCompletionHandler)
        }
        calendarView.scrollToItem(at: indexPath, at: position, animated: isAnimationEnabled)
        if isAnimationEnabled {
            if calendarOffsetIsAlreadyAtScrollPosition(forIndexPath: indexPath) {
                scrollViewDidEndScrollingAnimation(calendarView)
                scrollInProgress = false
                return
            }
        }
    }
    
    func targetPointForItemAt(indexPath: IndexPath) -> CGPoint? {
        guard let targetCellFrame = calendarView.layoutAttributesForItem(at: indexPath)?.frame else { return nil }
        
        let theTargetContentOffset: CGFloat = scrollDirection == .horizontal ? targetCellFrame.origin.x : targetCellFrame.origin.y
        var fixedScrollSize: CGFloat = 0
        switch scrollingMode {
        case .stopAtEachSection, .stopAtEachCalendarFrameWidth:
            if scrollDirection == .horizontal || (scrollDirection == .vertical && !thereAreHeaders) {
                // Horizontal has a fixed width.
                // Vertical with no header has fixed height
                fixedScrollSize = calendarViewLayout.sizeOfContentForSection(0)
            } else {
                // JT101 will remodel this code. Just a quick fix
                fixedScrollSize = calendarViewLayout.sizeOfContentForSection(0)
            }
        case .stopAtEach(customInterval: let customVal):
            fixedScrollSize = customVal
        default:
            break
        }
        
        let section = CGFloat(Int(theTargetContentOffset / fixedScrollSize))
        let destinationRectOffset = (fixedScrollSize * section)
        var x: CGFloat = 0
        var y: CGFloat = 0
        if scrollDirection == .horizontal {
            x = destinationRectOffset
        } else {
            y = destinationRectOffset
        }
        return CGPoint(x: x, y: y)
    }

    func calendarOffsetIsAlreadyAtScrollPosition(forOffset offset: CGPoint) -> Bool {
        var retval = false
        // If the scroll is set to animate, and the target content
        // offset is already on the screen, then the
        // didFinishScrollingAnimation
        // delegate will not get called. Once animation is on let's
        // force a scroll so the delegate MUST get caalled
        let theOffset = scrollDirection == .horizontal ? offset.x : offset.y
        let divValue = scrollDirection == .horizontal ? calendarView.frame.width : calendarView.frame.height
        let sectionForOffset = Int(theOffset / divValue)
        let calendarCurrentOffset = scrollDirection == .horizontal ? calendarView.contentOffset.x : calendarView.contentOffset.y
        if calendarCurrentOffset == theOffset ||
            (scrollingMode.pagingIsEnabled() &&
                (sectionForOffset ==  currentSection())) {
            retval = true
        }
        return retval
    }
    
    func calendarOffsetIsAlreadyAtScrollPosition(forIndexPath indexPath: IndexPath) -> Bool {
        var retval = false
        // If the scroll is set to animate, and the target content offset
        // is already on the screen, then the didFinishScrollingAnimation
        // delegate will not get called. Once animation is on let's force
        // a scroll so the delegate MUST get caalled
        if let attributes = calendarView.layoutAttributesForItem(at: indexPath) {
            let layoutOffset: CGFloat
            let calendarOffset: CGFloat
            if scrollDirection == .horizontal {
                layoutOffset = attributes.frame.origin.x
                calendarOffset = calendarView.contentOffset.x
            } else {
                layoutOffset = attributes.frame.origin.y
                calendarOffset = calendarView.contentOffset.y
            }
            if  calendarOffset == layoutOffset {
                retval = true
            }
        }
        return retval
    }
    /// Changes the calendar reading direction
    public func changeVisibleDirection(to orientation: ReadingOrientation) {
        if !calendarIsAlreadyLoaded {
            delayedExecutionClosure.append {[unowned self] in
                self.changeVisibleDirection(to: orientation)
            }
            return
        }
        
        if orientation == orientation { return }
        
        self.orientation = orientation
        calendarView.transform.a = orientation == .leftToRight ? 1 : -1
        calendarView.reloadData()
    }

    func scrollToHeaderInSection(_ section: Int,
                                 triggerScrollToDateDelegate: Bool = false,
                                 withAnimation animation: Bool = true,
                                 completionHandler: (() -> Void)? = nil) {
        if !thereAreHeaders {
            return
        }
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        let indexPath = IndexPath(item: 0, section: section)
        DispatchQueue.main.async {
            if let attributes = self.calendarView.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: indexPath) {
                if let validHandler = completionHandler {
                    self.delayedExecutionClosure.append(validHandler)
                }

                let maxYCalendarOffset = max(0, self.calendarView.contentSize.height - self.calendarView.frame.size.height)
                let topOfHeader = CGPoint(x: attributes.frame.origin.x,y: min(maxYCalendarOffset, attributes.frame.origin.y))
                
                self.scrollInProgress = true
                self.calendarView.setContentOffset(topOfHeader, animated: animation)
                if !animation {
                    self.scrollViewDidEndScrollingAnimation(self.calendarView)
                } else {
                    // If the scroll is set to animate, and the target
                    // content offset is already on the screen, then the
                    // didFinishScrollingAnimation
                    // delegate will not get called. Once animation is on
                    // let's force a scroll so the delegate MUST get caalled
                    if self.calendarOffsetIsAlreadyAtScrollPosition(forOffset: topOfHeader) {
                        self.scrollViewDidEndScrollingAnimation(self.calendarView)
                    }
                }
                self.scrollInProgress = false
            }
        }
    }
    
    func reloadData(checkDelegateDataSource shouldCheckDelegateDatasource: Bool,
                    withAnchorDate anchorDate: Date? = nil,
                    withAnimation animation: Bool = false,
                    completionHandler: (() -> Void)? = nil) {
        
        // Reload the datasource
        if shouldCheckDelegateDatasource {
            reloadDelegateDataSource()
        }
        
        layoutIfNeeded()
        
        if layoutNeedsUpdating {
            calendarViewLayout.clearCache()
            setupMonthInfoAndMap()
            calendarViewLayout.prepare()
            remapSelectedDatesWithCurrentLayout()
            layoutNeedsUpdating = false
        }
        
        // Re-select the dates that were selected prior to the reload
        if !selectedDates.isEmpty {
            let selectedDates = self.selectedDates
            var pathsAndCounterPaths = pathsFromDates(selectedDates)
            
            for date in selectedDates {
                if let counterPath = indexPathOfdateCellCounterPart(date, dateOwner: .thisMonth) {
                    pathsAndCounterPaths.append(counterPath)
                }
            }
            
            theSelectedIndexPaths = pathsAndCounterPaths
        }
        
        // Restore the selected index paths
        let restoreAfterReload = {[unowned self] in
            // The bounds of visible cells might have shifted, so reset them
            for cell in self.calendarView.visibleCells { cell.bounds.origin = CGPoint(x: 0, y: 0) }
            for indexPath in self.theSelectedIndexPaths { self.restoreSelectionStateForCellAtIndexPath(indexPath) }
        }
        
        // Restore the min date.
        setMinVisibleDate()
        
        if let validAnchorDate = anchorDate {
            // If we have a valid anchor date, this means we want to
            // scroll
            // This scroll should happen after the reload above
            calendarView.completionHandler = {[unowned self] in
                if self.thereAreHeaders {
                    self.scrollToHeaderForDate(
                        validAnchorDate,
                        triggerScrollToDateDelegate: false,
                        withAnimation: animation,
                        completionHandler: completionHandler)
                } else {
                    self.scrollToDate(validAnchorDate,
                                      triggerScrollToDateDelegate: false,
                                      animateScroll: animation,
                                      completionHandler: completionHandler)
                }
                
                restoreAfterReload()
            }
            calendarView.reloadData()
        } else {
            guard let validCompletionHandler = completionHandler else {
                calendarView.completionHandler = restoreAfterReload
                calendarView.reloadData()
                return
            }
            if scrollInProgress {
                delayedExecutionClosure.append {[unowned self] in
                    self.calendarView.completionHandler = {
                        restoreAfterReload()
                        validCompletionHandler()
                    }
                    self.calendarView.reloadData()
                }
            } else {
                calendarView.completionHandler = {
                    restoreAfterReload()
                    validCompletionHandler()
                }
                calendarView.reloadData()
            }
        }
    }

    func executeDelayedTasks() {
        let tasksToExecute = delayedExecutionClosure
        delayedExecutionClosure.removeAll()
        
        for aTaskToExecute in tasksToExecute {
            aTaskToExecute()
        }
    }

    // Only reload the dates if the datasource information has changed
    fileprivate func reloadDelegateDataSource() {
        if let
            newDateBoundary = dataSource?.configureCalendar(self) {
            // Jt101 do a check in each var to see if
            // user has bad star/end dates
            let newStartOfMonth = calendar.startOfMonth(for: newDateBoundary.startDate)
            let newEndOfMonth   = calendar.endOfMonth(for: newDateBoundary.endDate)
            let oldStartOfMonth = calendar.startOfMonth(for: startDateCache)
            let oldEndOfMonth   = calendar.endOfMonth(for: endDateCache)
            if newStartOfMonth != oldStartOfMonth ||
                newEndOfMonth != oldEndOfMonth ||
                newDateBoundary.calendar != cachedConfiguration.calendar ||
                newDateBoundary.numberOfRows != cachedConfiguration.numberOfRows ||
                newDateBoundary.generateInDates != cachedConfiguration.generateInDates ||
                newDateBoundary.generateOutDates != cachedConfiguration.generateOutDates ||
                newDateBoundary.firstDayOfWeek != cachedConfiguration.firstDayOfWeek ||
                newDateBoundary.hasStrictBoundaries != cachedConfiguration.hasStrictBoundaries {
                        layoutNeedsUpdating = true
            }
        }
    }

    func remapSelectedDatesWithCurrentLayout() {
        // the selected dates and paths will be retained. Ones that
        // are not available on the new layout will be removed.
        var indexPathsToReselect = [IndexPath]()
        
        for date in selectedDates {
            // add the index paths of the new layout
            let path = pathsFromDates([date])
            indexPathsToReselect.append(contentsOf: path)
            if
                !path.isEmpty,
                let possibleCounterPartDateIndex = indexPathOfdateCellCounterPart(date, dateOwner: DateOwner.thisMonth) {
                indexPathsToReselect.append(possibleCounterPartDateIndex)
            }
        }
        

        theSelectedDates = indexPathsToReselect.flatMap { return dateOwnerInfoFromPath($0)?.date }
        theSelectedIndexPaths = indexPathsToReselect
    }

    func calendarViewHeaderSizeForSection(_ section: Int) -> CGSize {
        var retval = CGSize.zero
        if
            thereAreHeaders,
            let validDate = monthInfoFromSection(section),
            let size = delegate?.calendar(self, sectionHeaderSizeFor: validDate.range, belongingTo: validDate.month) {
                retval = size
        }
        return retval
    }
}

extension JTAppleCalendarView {

    func indexPathOfdateCellCounterPart(_ date: Date,
                                        dateOwner: DateOwner) -> IndexPath? {
        if (cachedConfiguration.generateInDates == .off ||
            cachedConfiguration.generateInDates == .forFirstMonthOnly) &&
            cachedConfiguration.generateOutDates == .off {
            return nil
        }
        var retval: IndexPath?
        if dateOwner != .thisMonth {
            // If the cell is anything but this month, then the cell belongs
            // to either a previous of following month
            // Get the indexPath of the counterpartCell
            let counterPathIndex = pathsFromDates([date])
            if !counterPathIndex.isEmpty {
                retval = counterPathIndex[0]
            }
        } else {
            // If the date does belong to this month,
            // then lets find out if it has a counterpart date
            if date < startOfMonthCache || date > endOfMonthCache {
                return retval
            }
            guard let dayIndex = calendar
                        .dateComponents([.day], from: date).day else {
                print("Invalid Index")
                return nil
            }
            if case 1...13 = dayIndex {
                // then check the previous month
                // get the index path of the last day of the previous month
                let periodApart = calendar.dateComponents([.month], from: startOfMonthCache, to: date)
                guard
                    let monthSectionIndex = periodApart.month, monthSectionIndex - 1 >= 0 else {
                        // If there is no previous months,
                        // there are no counterpart dates
                        return retval
                }
                let previousMonthInfo = monthInfo[monthSectionIndex - 1]
                // If there are no postdates for the previous month,
                // then there are no counterpart dates
                if previousMonthInfo.outDates < 1 || dayIndex > previousMonthInfo.outDates {
                    return retval
                }
                guard
                    let prevMonth = calendar.date(byAdding: .month, value: -1, to: date),
                    let lastDayOfPrevMonth = calendar.endOfMonth(for: prevMonth) else {
                        assert(false, "Error generating date in indexPathOfdateCellCounterPart(). Contact the developer on github")
                        return retval
                }

                let indexPathOfLastDayOfPreviousMonth =
                    pathsFromDates([lastDayOfPrevMonth])
                if indexPathOfLastDayOfPreviousMonth.isEmpty {
                    print("out of range error in " +
                        "indexPathOfdateCellCounterPart() upper. " +
                        "This should not happen. Contact developer on github")
                    return retval
                }
                let lastDayIndexPath = indexPathOfLastDayOfPreviousMonth[0]
                var section = lastDayIndexPath.section
                var itemIndex = lastDayIndexPath.item + dayIndex
                // Determine if the sections/item needs to be adjusted
                let extraSection = itemIndex / numberOfItemsInSection(section)
                let extraIndex = itemIndex % numberOfItemsInSection(section)
                section += extraSection
                itemIndex = extraIndex
                let reCalcRapth = IndexPath(item: itemIndex, section: section)
                retval = reCalcRapth
            } else if case 25...31 = dayIndex { // check the following month
                let periodApart = calendar.dateComponents([.month], from: startOfMonthCache, to: date)
                let monthSectionIndex = periodApart.month!
                if monthSectionIndex + 1 >= monthInfo.count {
                    return retval
                }
                
                // If there is no following months, there are no counterpart dates
                let followingMonthInfo = monthInfo[monthSectionIndex + 1]
                if followingMonthInfo.inDates < 1 {
                    return retval
                }
                // If there are no predates for the following month then there are no counterpart dates
                let lastDateOfCurrentMonth = calendar.endOfMonth(for: date)!
                let lastDay = calendar.component(.day, from: lastDateOfCurrentMonth)
                let section = followingMonthInfo.startSection
                let index = dayIndex - lastDay + (followingMonthInfo.inDates - 1)
                if index < 0 {
                    return retval
                }
                retval = IndexPath(item: index, section: section)
            }
        }
        return retval
    }

    func setupMonthInfoDataForStartAndEndDate() -> CalendarData {
        var months = [Month]()
        var monthMap = [Int: Int]()
        var totalSections = 0
        var totalDays = 0
        if let validConfig = dataSource?.configureCalendar(self) {
            let comparison = validConfig.calendar.compare(validConfig.startDate, to: validConfig.endDate, toGranularity: .nanosecond)
            if comparison == ComparisonResult.orderedDescending {
                assert(false, "Error, your start date cannot be greater than your end date\n")
                return (CalendarData(months: [], totalSections: 0, sectionToMonthMap: [:], totalDays: 0))
            }
            
            // Set the new cache
            cachedConfiguration = validConfig
            
            if let
                startMonth = calendar.startOfMonth(for: validConfig.startDate),
                let endMonth = calendar.endOfMonth(for: validConfig.endDate) {
                startOfMonthCache = startMonth
                endOfMonthCache   = endMonth
                // Create the parameters for the date format generator
                let parameters = ConfigurationParameters(startDate: startOfMonthCache,
                                                         endDate: endOfMonthCache,
                                                         numberOfRows: validConfig.numberOfRows,
                                                         calendar: calendar,
                                                         generateInDates: validConfig.generateInDates,
                                                         generateOutDates: validConfig.generateOutDates,
                                                         firstDayOfWeek: validConfig.firstDayOfWeek,
                                                         hasStrictBoundaries: validConfig.hasStrictBoundaries)
                
                let generatedData = dateGenerator.setupMonthInfoDataForStartAndEndDate(parameters)
                months = generatedData.months
                monthMap = generatedData.monthMap
                totalSections = generatedData.totalSections
                totalDays = generatedData.totalDays
            }
        }
        let data = CalendarData(months: months, totalSections: totalSections, sectionToMonthMap: monthMap, totalDays: totalDays)
        return data
    }

    func pathsFromDates(_ dates: [Date]) -> [IndexPath] {
        var returnPaths: [IndexPath] = []
        for date in dates {
            if  calendar.startOfDay(for: date) >= startOfMonthCache! && calendar.startOfDay(for: date) <= endOfMonthCache! {
                if  calendar.startOfDay(for: date) >= startOfMonthCache! && calendar.startOfDay(for: date) <= endOfMonthCache! {
                    let periodApart = calendar.dateComponents([.month], from: startOfMonthCache, to: date)
                    let day = calendar.dateComponents([.day], from: date).day!
                    let monthSectionIndex = periodApart.month
                    let currentMonthInfo = monthInfo[monthSectionIndex!]
                    if let indexPath = currentMonthInfo.indexPath(forDay: day) {
                        returnPaths.append(indexPath)
                    }
                }
            }
        }
        return returnPaths
    }
    
    /// Add gesture recognizers to the calendar
    override open func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        calendarView.addGestureRecognizer(gestureRecognizer)
    }
    
    func cellStateFromIndexPath(_ indexPath: IndexPath, withDateInfo info: (date: Date, owner: DateOwner)? = nil, cell: JTAppleDayCell? = nil) -> CellState {
        let validDateInfo: (date: Date, owner: DateOwner)
        if let nonNilDateInfo = info {
            validDateInfo = nonNilDateInfo
        } else {
            guard let newDateInfo = dateOwnerInfoFromPath(indexPath) else {
                developerError(string: "Error this should not be nil. " +
                    "Contact developer Jay on github by opening a request")
                return CellState(isSelected: false,
                                 text: "",
                                 dateBelongsTo: .thisMonth,
                                 date: Date(),
                                 day: .sunday,
                                 row: {return 0},
                                 column: {return 0},
                                 dateSection: {
                                    return (range: (Date(), Date()), month: 0, rowCount: 0)
                                 },
                                 selectedPosition: {return .left},
                                 cell: {return nil})
            }
            validDateInfo = newDateInfo
        }
        let date = validDateInfo.date
        let dateBelongsTo = validDateInfo.owner
        
        let currentDay = calendar.component(.day, from: date)
        let componentWeekDay = calendar.component(.weekday, from: date)
        let cellText = String(describing: currentDay)
        let dayOfWeek = DaysOfWeek(rawValue: componentWeekDay)!
        
        
        let rangePosition = { () -> SelectionRangePosition in
            if !self.theSelectedIndexPaths.contains(indexPath) { return .none }
            if self.selectedDates.count == 1 { return .full }
            
            guard
                let nextIndexPath = self.calendarViewLayout.indexPath(direction: .next, of: indexPath.section, item: indexPath.item),
                let previousIndexPath = self.calendarViewLayout.indexPath(direction: .previous, of: indexPath.section, item: indexPath.item) else {
                    return .full
            }
            
            let selectedIndicesContainsPreviousPath = self.theSelectedIndexPaths.contains(previousIndexPath)
            let selectedIndicesContainsFollowingPath = self.theSelectedIndexPaths.contains(nextIndexPath)

            var position: SelectionRangePosition
            if selectedIndicesContainsPreviousPath == selectedIndicesContainsFollowingPath {
                position = selectedIndicesContainsPreviousPath == false ? .full : .middle
            } else {
                position = selectedIndicesContainsPreviousPath == false ? .left : .right
            }
            
            return position
        }
        let cellState = CellState(
            isSelected: theSelectedIndexPaths.contains(indexPath),
            text: cellText,
            dateBelongsTo: dateBelongsTo,
            date: date,
            day: dayOfWeek,
            row: { return indexPath.item / maxNumberOfDaysInWeek },
            column: { return indexPath.item % maxNumberOfDaysInWeek },
            dateSection: {
                return self.monthInfoFromSection(indexPath.section)!
            },
            selectedPosition: rangePosition,
            cell: { return cell }
        )
        return cellState
    }

    func batchReloadIndexPaths(_ indexPaths: [IndexPath]) {
        let visiblePaths = calendarView.indexPathsForVisibleItems
        let pathsToReload = indexPaths.filter { visiblePaths.contains($0)}
        if pathsToReload.isEmpty { return }
        
        UICollectionView.performWithoutAnimation {
            self.calendarView.performBatchUpdates({[unowned self] in
                self.calendarView.reloadItems(at: pathsToReload)
            })
        }
    }

    func addCellToSelectedSetIfUnselected(_ indexPath: IndexPath, date: Date) {
        if theSelectedIndexPaths.contains(indexPath) == false {
            theSelectedIndexPaths.append(indexPath)
            theSelectedDates.append(date)
        }
    }

    func deleteCellFromSelectedSetIfSelected(_ indexPath: IndexPath) {
        if let index = theSelectedIndexPaths.index(of: indexPath) {
            theSelectedIndexPaths.remove(at: index)
            theSelectedDates.remove(at: index)
        }
    }

    func deselectCounterPartCellIndexPath(_ indexPath: IndexPath, date: Date, dateOwner: DateOwner) -> IndexPath? {
        if let counterPartCellIndexPath =
            indexPathOfdateCellCounterPart(date,
                                           dateOwner: dateOwner) {
            deleteCellFromSelectedSetIfSelected(counterPartCellIndexPath)
            return counterPartCellIndexPath
        }
        return nil
    }

    func selectCounterPartCellIndexPathIfExists(_ indexPath: IndexPath, date: Date, dateOwner: DateOwner) -> IndexPath? {
        if let counterPartCellIndexPath = indexPathOfdateCellCounterPart(date, dateOwner: dateOwner) {
            let dateComps = calendar.dateComponents([.month, .day, .year], from: date)
            guard let counterpartDate = calendar.date(from: dateComps) else {
                return nil
            }
            addCellToSelectedSetIfUnselected(counterPartCellIndexPath, date: counterpartDate)
            return counterPartCellIndexPath
        }
        return nil
    }

    func monthInfoFromSection(_ section: Int) -> (range: (start: Date, end: Date), month: Int, rowCount: Int)? {
            guard let monthIndex = monthMap[section] else {
                return nil
            }
            let monthData = monthInfo[monthIndex]
            
            guard
                let monthDataMapSection = monthData.sectionIndexMaps[section],
                let indices = monthData.boundaryIndicesFor(section: monthDataMapSection) else {
                    return nil
            }
            let startIndexPath = IndexPath(item: indices.startIndex, section: section)
            let endIndexPath = IndexPath(item: indices.endIndex, section: section)
            guard
                let startDate = dateOwnerInfoFromPath(startIndexPath)?.date,
                let endDate = dateOwnerInfoFromPath(endIndexPath)?.date else {
                    return nil
            }
            if let monthDate = calendar.date(byAdding: .month, value: monthIndex, to: startDateCache) {
                let monthNumber = calendar.dateComponents([.month], from: monthDate)
                let numberOfRowsForSection = monthData.numberOfRows(for: section, developerSetRows: numberOfRows())
                return ((startDate, endDate), monthNumber.month!, numberOfRowsForSection)
            }
            return nil
    }
    
    func setMinVisibleDate() { // jt101 for setting proposal
        let minIndices = minimumVisibleIndexPaths()
        switch (minIndices.headerIndex, minIndices.cellInfo.indexPath) {
        case (.some(let path), nil):
            lastIndexOffset = (path, UICollectionElementCategory.supplementaryView)
        case (nil, .some(let path)):
            lastIndexOffset = (path, UICollectionElementCategory.cell)
        case (.some(let hPath), (.some(let cPath))):
            if hPath <= cPath {
                lastIndexOffset = (hPath, UICollectionElementCategory.supplementaryView)
            } else {
                lastIndexOffset = (cPath, UICollectionElementCategory.cell)
            }
        default:
            break
        }
    }
    
    // This function ignores decoration views //JT101 for setting proposal
    func minimumVisibleIndexPaths() -> (cellInfo:(indexPath: IndexPath?, state: CellState?), headerIndex: IndexPath?) {
        let visibleItems: [UICollectionViewLayoutAttributes] = scrollDirection == .horizontal ? visibleElements(excludeHeaders: true) : visibleElements()
        
        var cells: [IndexPath] = []
        var headers: [IndexPath] = []
        for item in visibleItems {
            if item.representedElementCategory == .cell {
                cells.append(item.indexPath)
            } else {
                headers.append(item.indexPath)
            }
        }
        
        var cellState: CellState?
        if let validMinCellIndex = cells.min() {
            cellState = cellStateFromIndexPath(validMinCellIndex)
        }

        return ((cells.min(), cellState), headers.min())
    }

    /// Retrieves the current section
    public func currentSection() -> Int? {
        return minimumVisibleIndexPaths().cellInfo.indexPath?.section
    }
    
    func visibleElements(excludeHeaders: Bool? = false, from rect: CGRect? = nil) -> [UICollectionViewLayoutAttributes] {
        let aRect = rect ?? CGRect(x: calendarView.contentOffset.x + 1, y: calendarView.contentOffset.y + 1, width: calendarView.frame.width - 2, height: calendarView.frame.height - 2)
        guard let attributes = calendarViewLayout.layoutAttributesForElements(in: aRect), !attributes.isEmpty else {
            return []
        }
        if excludeHeaders == true {
            return attributes.filter { $0.representedElementKind != UICollectionElementKindSectionHeader }
        }
        return attributes
    }
    
    func dateSegmentInfoFrom(visible indexPaths: [IndexPath]) -> DateSegmentInfo {
        var inDates   = [Date]()
        var monthDates = [Date]()
        var outDates  = [Date]()
        var inDateIndexes   = [IndexPath]()
        var monthDateIndexes = [IndexPath]()
        var outDateIndexes  = [IndexPath]()
        
        for indexPath in indexPaths {
            let info = dateOwnerInfoFromPath(indexPath)
            if let validInfo = info  {
                switch validInfo.owner {
                case .thisMonth:
                    monthDates.append(validInfo.date)
                    monthDateIndexes.append(indexPath)
                case .previousMonthWithinBoundary, .previousMonthOutsideBoundary:
                    inDates.append(validInfo.date)
                    inDateIndexes.append(indexPath)
                default:
                    outDateIndexes.append(indexPath)
                    outDates.append(validInfo.date)
                }
            }
        }
        
        let retval = DateSegmentInfo(indates: inDates, monthDates: monthDates, outdates: outDates, indateIndexes: inDateIndexes, monthDateIndexes: monthDateIndexes, outdateIndexes: outDateIndexes)
        return retval
    }

    func dateOwnerInfoFromPath(_ indexPath: IndexPath) -> (date: Date, owner: DateOwner)? { // Returns nil if date is out of scope
        guard let monthIndex = monthMap[indexPath.section] else {
            return nil
        }
        let monthData = monthInfo[monthIndex]
        // Calculate the offset
        let offSet: Int
        var numberOfDaysToAddToOffset: Int = 0
        switch monthData.sectionIndexMaps[indexPath.section]! {
        case 0:
            offSet = monthData.inDates
        default:
            offSet = 0
            let currentSectionIndexMap = monthData.sectionIndexMaps[indexPath.section]!
            numberOfDaysToAddToOffset = monthData.sections[0..<currentSectionIndexMap].reduce(0, +)
            numberOfDaysToAddToOffset -= monthData.inDates
        }
                                                        
        var dayIndex = 0
        var dateOwner: DateOwner = .thisMonth
        let date: Date?
        if indexPath.item >= offSet && indexPath.item + numberOfDaysToAddToOffset < monthData.numberOfDaysInMonth + offSet {
            // This is a month date
            dayIndex = monthData.startDayIndex + indexPath.item - offSet + numberOfDaysToAddToOffset
            date = calendar.date(byAdding: .day, value: dayIndex, to: startOfMonthCache)
        } else if indexPath.item < offSet {
            // This is a preDate
            dayIndex = indexPath.item - offSet  + monthData.startDayIndex
            date = calendar.date(byAdding: .day, value: dayIndex, to: startOfMonthCache)
            if date! < startOfMonthCache {
                dateOwner = .previousMonthOutsideBoundary
            } else {
                dateOwner = .previousMonthWithinBoundary
            }
        } else {
            // This is a postDate
            dayIndex =  monthData.startDayIndex - offSet + indexPath.item + numberOfDaysToAddToOffset
            date = calendar.date(byAdding: .day, value: dayIndex, to: startOfMonthCache)
            if date! > endOfMonthCache {
                dateOwner = .followingMonthOutsideBoundary
            } else {
                dateOwner = .followingMonthWithinBoundary
            }
        }
        guard let validDate = date else { return nil }
        return (validDate, dateOwner)
    }

}
