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

    lazy var dateGenerator: JTAppleDateConfigGenerator = {
        var configurator = JTAppleDateConfigGenerator()
        configurator.delegate = self
        return configurator
    }()

    /// Configures the behavior of the scrolling mode of the calendar
    public enum ScrollingMode {
        case stopAtEachCalendarFrameWidth,
        stopAtEachSection,
        stopAtEach(customInterval: CGFloat),
        nonStopToSection(withResistance: CGFloat),
        nonStopToCell(withResistance: CGFloat),
        nonStopTo(customInterval: CGFloat, withResistance: CGFloat),
        none

        func  pagingIsEnabled() -> Bool {
            switch self {
            case .stopAtEachCalendarFrameWidth: return true
            default: return false
            }
        }

    }

    var calendarIsAlreadyLoaded: Bool {
        get {
            if let alreadyLoaded = finalLoadable, alreadyLoaded {
                return true
            }
            return false
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

    /// Enables and disables animations when scrolling to and from date-cells
    open var animationsEnabled = true

    /// The scroll direction of the sections in JTAppleCalendar.
    open var direction: UICollectionViewScrollDirection = .horizontal {
        didSet {
            if oldValue == direction {
                return
            }
            calendarViewLayout.scrollDirection = direction
            updateLayoutItemSize()
            layoutNeedsUpdating = true
        }
    }

    /// Enables/Disables multiple selection on JTAppleCalendar
    open var allowsMultipleSelection: Bool = false {
        didSet {
            self.calendarView.allowsMultipleSelection =
            allowsMultipleSelection
        }
    }

    /// Alerts the calendar that range selection will be checked. If you are
    /// not using rangeSelection and you enable this,
    /// then whenever you click on a datecell, you may notice a very fast
    /// refreshing of the date-cells both left and right of the cell you
    /// just selected.
    open var rangeSelectionWillBeUsed = false
    var lastSavedContentOffset: CGFloat = 0.0
    var triggerScrollToDateDelegate: Bool? = true
    // Keeps track of item size for a section. This is an optimization
    var scrollInProgress = false

    var calendarViewLayout: JTAppleCalendarLayout {
        get {
            guard let layout = calendarView.collectionViewLayout as?
                JTAppleCalendarLayout else {
                    developerError(string: "Calendar layout is not of type " +
                        "`JTAppleCalendarLayout`.")
                    return JTAppleCalendarLayout(withDelegate: self)
            }
            return layout
        }
    }

    var layoutNeedsUpdating = false {
        didSet {
            print("")
        }
    }

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
        self.frame = super.frame
    }

    /// The frame rectangle which defines the view's location and size in
    /// its superview coordinate system.
    override open var frame: CGRect {
        didSet {
            calendarView.frame = CGRect(x: 0, y: 0, width: self.frame.width,
                                        height: self.frame.height)
            updateLayoutItemSize()
            if calendarViewLayout.itemSize != lastSize {
                lastSize = calendarViewLayout.itemSize
                if delegate != nil {
                    var anInitialCompletionHandler: (() -> Void)?
                    if finalLoadable == nil { // This will only be set once
                        finalLoadable = true
                        anInitialCompletionHandler = {
                            self.executeDelayedTasks()
                        }
                    }
                    reloadData(completionHandler: anInitialCompletionHandler)
                }
            }
        }
    }

    /// The object that acts as the delegate of the calendar view.
    weak open var delegate: JTAppleCalendarViewDelegate?

    var delayedExecutionClosure: [(() -> Void)] = []
    var lastSize = CGSize.zero
    var finalLoadable: Bool?

    var currentSectionPage: Int {
        return calendarViewLayout
            .sectionFromRectOffset(calendarView.contentOffset)
    }

    var startDateCache: Date {
        get {
            return cachedConfiguration.startDate
        }
    }

    var endDateCache: Date {
        get {
            return cachedConfiguration.endDate
        }
    }

    var calendar: Calendar {
        get {
            return cachedConfiguration.calendar
        }
    }

    lazy var cachedConfiguration: ConfigurationParameters = {
        [weak self] in
        guard let  config = self!.dataSource?.configureCalendar(self!) else {
            assert(false, "DataSource is not set")
            return ConfigurationParameters(
                startDate: Date(),
                endDate: Date(),
                numberOfRows: 0,
                calendar: Calendar(identifier: .gregorian),
                generateInDates: false,
                generateOutDates: .off,
                firstDayOfWeek: .sunday
            )
        }
        return ConfigurationParameters(startDate: config.startDate,
                endDate: config.endDate,
                numberOfRows: config.numberOfRows,
                calendar: config.calendar,
                generateInDates: config.generateInDates,
                generateOutDates: config.generateOutDates,
                firstDayOfWeek: config.firstDayOfWeek
        )
    }()

    // Set the start of the month
    lazy var startOfMonthCache: Date = {
        [weak self] in
        if let startDate = Date.startOfMonth(for: self!.startDateCache,
                                             using: self!.calendar) {
            return startDate
        }
        assert(false, "Error: StartDate was not correctly generated for " +
            "start of month. current date was used: \(Date())")
        return Date()
        }()

    // Set the end of month
    lazy var endOfMonthCache: Date = {
        [weak self] in
        if let endDate = Date.endOfMonth(for: self!.endDateCache,
                                         using: self!.calendar) {
            return endDate
        }
        assert(false, "Error: Date was not correctly generated for end " +
            "of month. current date was used: \(Date())")
        return Date()
        }()

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

    lazy var theData: CalendarData = {
        [weak self] in
        return self!.setupMonthInfoDataForStartAndEndDate()
    }()

    var monthInfo: [Month] {
        get {
            return theData.months
        }
        set {
            theData.months = monthInfo
        }
    }

    var monthMap: [Int: Int] {
        get {
            return theData.monthMap
        }
        set {
            theData.monthMap = monthMap
        }
    }

    var numberOfMonths: Int {
        get {
            return monthInfo.count
        }
    }

    var totalDays: Int {
        get {
            return theData.totalDays
        }
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        return collectionView(calendarView, numberOfItemsInSection: section)
    }

    /// Cell inset padding for the x and y axis
    /// of every date-cell on the calendar view.
    open var cellInset: CGPoint = CGPoint(x: 3, y: 3)
    var cellViewSource: JTAppleCalendarViewSource!
    var registeredHeaderViews: [JTAppleCalendarViewSource] = []

    /// Enable or disable swipe scrolling of the calendar with this variable
    open var scrollEnabled: Bool = true {
        didSet {
            calendarView.isScrollEnabled = scrollEnabled
        }
    }

    // Configure the scrolling behavior
    open var scrollingMode: ScrollingMode = .stopAtEachCalendarFrameWidth {
        didSet {
            switch scrollingMode {
            case .stopAtEachCalendarFrameWidth:
                calendarView.decelerationRate =
                UIScrollViewDecelerationRateFast
            case .stopAtEach, .stopAtEachSection:
                calendarView.decelerationRate =
                UIScrollViewDecelerationRateFast
            case .nonStopToSection, .nonStopToCell, .nonStopTo, .none:
                calendarView.decelerationRate =
                UIScrollViewDecelerationRateNormal
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

    lazy var calendarView: UICollectionView = {
        let layout = JTAppleCalendarLayout(withDelegate: self)
        layout.scrollDirection = self.direction
        let cv = UICollectionView(frame: CGRect.zero,
                                  collectionViewLayout: layout)
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

    fileprivate func updateLayoutItemSize() {
        if dataSource == nil {
            return
        } // If the delegate is not set yet, then return, becaus
          // edelegate methods will be called on the layout
        let layout = calendarViewLayout

        // Invalidate the layout

        // Default Item height
        var height: CGFloat = (self.calendarView.bounds.size.height -
            layout.headerReferenceSize.height) /
            CGFloat(cachedConfiguration.numberOfRows)
        // Default Item width
        var width: CGFloat = self.calendarView.bounds.size.width /
            CGFloat(maxNumberOfDaysInWeek)

        if let userSetItemSize = self.itemSize {
            if direction == .vertical {
                height = userSetItemSize
            } else {
                width = userSetItemSize
            }
        }
        let size = CGSize(width: width, height: height)

        if lastSize != size {
            layout.invalidateLayout()
            layout.clearCache()
            layoutNeedsUpdating = true
            layout.itemSize = size
        }
    }

    /// Initializes and returns a newly allocated
    /// view object with the specified frame rectangle.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
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
        self.initialSetup()
    }

    // MARK: Setup
    func initialSetup() {
        self.clipsToBounds = true
        self.calendarView.register(JTAppleDayCell.self,
                        forCellWithReuseIdentifier: cellReuseIdentifier)
        self.addSubview(self.calendarView)
    }

    func restoreSelectionStateForCellAtIndexPath(_ indexPath: IndexPath) {
        if theSelectedIndexPaths.contains(indexPath) {
            calendarView.selectItem(
                at: indexPath,
                animated: false,
                scrollPosition: UICollectionViewScrollPosition()
            )
        }
    }

    func validForwardAndBackwordSelectedIndexes(
                    forIndexPath indexPath: IndexPath) -> [IndexPath] {
        var retval = [IndexPath]()
        if let validForwardIndex = calendarView
            .layoutAttributesForItem(
                at: IndexPath(item: indexPath.item + 1,
                              section: indexPath.section)),
            theSelectedIndexPaths.contains(validForwardIndex.indexPath) {
                retval.append(validForwardIndex.indexPath)
        }
        if let validBackwardIndex = calendarView
            .collectionViewLayout.layoutAttributesForItem(
                at: IndexPath(item: indexPath.item - 1,
                              section: indexPath.section)),
            theSelectedIndexPaths.contains(validBackwardIndex.indexPath) {
                retval.append(validBackwardIndex.indexPath)
        }
        return retval
    }

    func calendarOffsetIsAlreadyAtScrollPosition(
        forIndexPath indexPath: IndexPath) -> Bool? {
            var retval: Bool?
            // If the scroll is set to animate, and the target content offset
            // is already on the screen, then the didFinishScrollingAnimation
            // delegate will not get called. Once animation is on let's force
            // a scroll so the delegate MUST get caalled
            if let attributes = self.calendarView
                .layoutAttributesForItem(at: indexPath) {
                let layoutOffset: CGFloat
                let calendarOffset: CGFloat
                if direction == .horizontal {
                    layoutOffset = attributes.frame.origin.x
                    calendarOffset = calendarView.contentOffset.x
                } else {
                    layoutOffset = attributes.frame.origin.y
                    calendarOffset = calendarView.contentOffset.y
                }
                if  calendarOffset == layoutOffset ||
                    (scrollingMode.pagingIsEnabled() &&
                        (indexPath.section ==  currentSectionPage)) {
                            retval = true
                } else {
                    retval = false
                }
            }
            return retval
    }

    func calendarOffsetIsAlreadyAtScrollPosition(
        forOffset offset: CGPoint) -> Bool? {
            var retval: Bool?
            // If the scroll is set to animate, and the target content
            // offset is already on the screen, then the
            // didFinishScrollingAnimation
            // delegate will not get called. Once animation is on let's
            // force a scroll so the delegate MUST get caalled
            let theOffset = direction == .horizontal ? offset.x : offset.y
            let divValue = direction == .horizontal ?
                calendarView.frame.width : calendarView.frame.height
            let sectionForOffset = Int(theOffset / divValue)
            let calendarCurrentOffset = direction == .horizontal ?
                calendarView.contentOffset.x : calendarView.contentOffset.y
            if calendarCurrentOffset == theOffset ||
                    (scrollingMode.pagingIsEnabled() &&
                    (sectionForOffset ==  currentSectionPage)) {
                retval = true
            } else {
                retval = false
            }
            return retval
    }

    func firstDayIndexForMonth(_ date: Date) -> Int {
        let firstDayCalValue: Int
        switch cachedConfiguration.firstDayOfWeek {
        case .monday: firstDayCalValue = 6
        case .tuesday: firstDayCalValue = 5
        case .wednesday: firstDayCalValue = 4
        case .thursday: firstDayCalValue = 10
        case .friday: firstDayCalValue = 9
        case .saturday: firstDayCalValue = 8
        default: firstDayCalValue = 7
        }
        var firstWeekdayOfMonthIndex =
            calendar.component(.weekday, from: date)
        firstWeekdayOfMonthIndex -= 1
        // firstWeekdayOfMonthIndex should be 0-Indexed
        // push it modularly so that we take it back one day so that the
        // first day is Monday instead of Sunday which is the default
        return (firstWeekdayOfMonthIndex + firstDayCalValue) % 7
    }

    func scrollToHeaderInSection(_ section: Int,
                                 triggerScrollToDateDelegate: Bool = false,
                                 withAnimation animation: Bool = true,
                                 completionHandler: (() -> Void)? = nil) {
        if registeredHeaderViews.count < 1 {
            return
        }
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        let indexPath = IndexPath(item: 0, section: section)
        delayRunOnMainThread(0.0) {
            if let attributes = self.calendarView
                    .layoutAttributesForSupplementaryElement(
                        ofKind: UICollectionElementKindSectionHeader,
                        at: indexPath) {

                if let validHandler = completionHandler {
                    self.delayedExecutionClosure.append(validHandler)
                }
                let topOfHeader = CGPoint(x: attributes.frame.origin.x,
                                          y: attributes.frame.origin.y)
                self.scrollInProgress = true
                self.calendarView.setContentOffset(topOfHeader,
                                                   animated: animation)
                if  !animation {
                    self.scrollViewDidEndScrollingAnimation(self.calendarView)
                    self.scrollInProgress = false
                } else {
                    // If the scroll is set to animate, and the target
                    // content offset is already on the screen, then the
                    // didFinishScrollingAnimation
                    // delegate will not get called. Once animation is on
                    // let's force a scroll so the delegate MUST get caalled
                    if let check = self
                            .calendarOffsetIsAlreadyAtScrollPosition(
                                forOffset: topOfHeader), check == true {

                        self.scrollViewDidEndScrollingAnimation(
                                                        self.calendarView)
                        self.scrollInProgress = false
                    }
                }
            }
        }
    }

    func reloadData(checkDelegateDataSource check: Bool,
                    withAnchorDate anchorDate: Date? = nil,
                    withAnimation animation: Bool = false,
                    completionHandler: (() -> Void)? = nil) {

        // Reload the datasource
        if check {
            reloadDelegateDataSource()
        }
        var layoutWasUpdated: Bool?
        if layoutNeedsUpdating {
            self.configureChangeOfRows()
            self.layoutNeedsUpdating = false
            layoutWasUpdated = true
        }
        // Reload the data
        self.calendarView.reloadData()
        // Restore the selected index paths
        for indexPath in theSelectedIndexPaths {
            restoreSelectionStateForCellAtIndexPath(indexPath)
        }
        delayRunOnMainThread(0.0) {
            let scrollToDate = { (date: Date) -> Void in
                if self.registeredHeaderViews.count < 1 {
                    self.scrollToDate(date,
                                      triggerScrollToDateDelegate: false,
                                      animateScroll: animation,
                                      completionHandler: completionHandler)
                } else {
                    self.scrollToHeaderForDate(
                        date,
                        triggerScrollToDateDelegate: false,
                        withAnimation: animation,
                        completionHandler: completionHandler
                    )
                }
            }
            if let validAnchorDate = anchorDate {
                // If we have a valid anchor date, this means we want to
                // scroll
                // This scroll should happen after the reload above
                scrollToDate(validAnchorDate)
            } else {
                if layoutWasUpdated == true {
                    // This is a scroll done after a layout reset and dev
                    // didnt set an anchor date. If a scroll is in progress,
                    // then cancel this one and
                    // allow it to take precedent
                    if !self.scrollInProgress {
                        if let validCompletionHandler = completionHandler {
                            validCompletionHandler()
                        }
//                        self.calendarView.scrollToItem(
//                        at: IndexPath(item: 0, section:0),
//                        at: .left, animated: false)
//                        scrollToDate(self.startOfMonthCache)
                    } else {
                        if let validCompletionHandler = completionHandler {
                            self.delayedExecutionClosure
                                .append(validCompletionHandler)
                        }
                    }
                } else {
                    if let validCompletionHandler = completionHandler {
                        if self.scrollInProgress {
                            self.delayedExecutionClosure
                                .append(validCompletionHandler)
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
        for aTaskToExecute in tasksToExecute {
            aTaskToExecute()
        }
        delayedExecutionClosure.removeAll()
    }

    // Only reload the dates if the datasource information has changed
    fileprivate func reloadDelegateDataSource() {
        if let
            newDateBoundary = dataSource?.configureCalendar(self) {
            // Jt101 do a check in each var to see if
            // user has bad star/end dates
            let newStartOfMonth =
                Date.startOfMonth(for: newDateBoundary.startDate,
                                  using: cachedConfiguration.calendar)
            let newEndOfMonth =
                Date.endOfMonth(for: newDateBoundary.startDate,
                                using: cachedConfiguration.calendar)
            let oldStartOfMonth =
                Date.startOfMonth(for: cachedConfiguration.startDate,
                                  using: cachedConfiguration.calendar)
            let oldEndOfMonth =
                Date.endOfMonth(for: cachedConfiguration.startDate,
                                using: cachedConfiguration.calendar)
            if newStartOfMonth != oldStartOfMonth ||
                newEndOfMonth != oldEndOfMonth ||
                newDateBoundary.calendar != cachedConfiguration.calendar ||
                newDateBoundary.numberOfRows !=
                    cachedConfiguration.numberOfRows ||
                newDateBoundary.generateInDates !=
                    cachedConfiguration.generateInDates ||
                newDateBoundary.generateOutDates !=
                    cachedConfiguration.generateOutDates ||
                newDateBoundary.firstDayOfWeek !=
                    cachedConfiguration.firstDayOfWeek {

                        setupMonthInfoAndMap()
                        layoutNeedsUpdating = true
            }
        }
    }

    func configureChangeOfRows() {
        let layout = calendarViewLayout
        layout.clearCache()
        layout.prepare()
        // the selected dates and paths will be retained. Ones that
        // are not available on the new layout will be removed.
        var indexPathsToReselect = [IndexPath]()
        var newDates = [Date]()
        for date in selectedDates {
            // add the index paths of the new layout
            let path = pathsFromDates([date])
            indexPathsToReselect.append(contentsOf: path)
            if
                path.count > 0,
                let possibleCounterPartDateIndex =
                indexPathOfdateCellCounterPart(date, indexPath: path[0],
                                        dateOwner: DateOwner.thisMonth) {
                indexPathsToReselect.append(possibleCounterPartDateIndex)
            }
        }
        for path in indexPathsToReselect {
            if let date = dateInfoFromPath(path)?.date {
                newDates.append(date)
            }
        }
        theSelectedDates = newDates
        theSelectedIndexPaths = indexPathsToReselect
    }

    func calendarViewHeaderSizeForSection(_ section: Int) -> CGSize {
        var retval = CGSize.zero
        if registeredHeaderViews.count > 0 {
            if let validDate = monthInfoFromSection(section),
                let size = delegate?.calendar(self,
                                    sectionHeaderSizeFor: validDate.range,
                                    belongingTo: validDate.month) {
                retval = size
            }
        }
        return retval
    }

}

extension JTAppleCalendarView {

    func indexPathOfdateCellCounterPart(_ date: Date,
                                        indexPath: IndexPath,
                                        dateOwner: DateOwner) -> IndexPath? {
        if cachedConfiguration.generateInDates == false &&
            cachedConfiguration.generateOutDates == .off {
            return nil
        }
        var retval: IndexPath?
        if dateOwner != .thisMonth {
            // If the cell is anything but this month, then the cell belongs
            // to either a previous of following month
            // Get the indexPath of the counterpartCell
            let counterPathIndex = pathsFromDates([date])
            if counterPathIndex.count > 0 {
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
                let periodApart = calendar.dateComponents([.month],
                                        from: startOfMonthCache, to: date)
                guard let monthSectionIndex = periodApart.month,
                    monthSectionIndex - 1 >= 0 else {
                        // If there is no previous months,
                        // there are no counterpart dates
                        return retval
                }
                let previousMonthInfo = monthInfo[monthSectionIndex - 1]
                // If there are no postdates for the previous month,
                // then there are no counterpart dates
                if previousMonthInfo.postDates < 1 ||
                    dayIndex > previousMonthInfo.postDates {
                    return retval
                }
                guard let prevMonth = calendar
                        .date(byAdding: .month, value: -1, to: date),
                    let lastDayOfPrevMonth = Date
                        .endOfMonth(for: prevMonth, using: calendar) else {
                            assert(false, "Error generating date in " +
                                "indexPathOfdateCellCounterPart(). " +
                                "Contact the developer on github")
                            return retval
                }

                let indexPathOfLastDayOfPreviousMonth =
                    pathsFromDates([lastDayOfPrevMonth])
                if indexPathOfLastDayOfPreviousMonth.count < 1 {
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
            } else if case 26...31 = dayIndex { // check the following month
                let periodApart = calendar.dateComponents([.month],
                                        from: startOfMonthCache, to: date)
                let monthSectionIndex = periodApart.month!
                if monthSectionIndex + 1 >= monthInfo.count {
                    return retval
                }// If there is no following months,
                 // there are no counterpart dates

                let followingMonthInfo = monthInfo[monthSectionIndex + 1]
                if followingMonthInfo.preDates < 1 {
                    return retval
                } // If there are no predates for the following month,
                  // then there are no counterpart dates
                let lastDateOfCurrentMonth =
                    Date.endOfMonth(for: date, using: calendar)!
                let lastDay = calendar.component(.day,
                                                 from: lastDateOfCurrentMonth)
                let section = followingMonthInfo.startSection
                let index = dayIndex - lastDay +
                    (followingMonthInfo.preDates - 1)
                if index < 0 {
                    return retval
                }
                retval = IndexPath(item: index, section: section)
            }
        }
        return retval
    }

    func scrollToSection(_ section: Int,
                         triggerScrollToDateDelegate: Bool = false,
                         animateScroll: Bool = true,
                         completionHandler: (() -> Void)?) {
        if scrollInProgress {
            return
        }
        if let date = dateInfoFromPath(IndexPath(
            item: maxNumberOfDaysInWeek - 1, section: section))?.date {
                let recalcDate = Date.startOfMonth(for: date,
                                                   using: calendar)!
                self.scrollToDate(recalcDate,
                                  triggerScrollToDateDelegate:
                                      triggerScrollToDateDelegate,
                                  animateScroll: animateScroll,
                                  preferredScrollPosition: nil,
                                  completionHandler: completionHandler)
        }
    }

    func setupMonthInfoDataForStartAndEndDate() -> CalendarData {
        var months = [Month]()
        var monthMap = [Int: Int]()
        var totalSections = 0
        var totalDays = 0
        if let validConfig = dataSource?.configureCalendar(self) {
            // check if the dates are in correct order
            if validConfig.calendar.compare(
                validConfig.startDate, to: validConfig.endDate,
                toGranularity: .nanosecond) ==
                    ComparisonResult.orderedDescending {
                        assert(false, "Error, your start date cannot be " +
                            "greater than your end date\n")
                        return (CalendarData(months: [], totalSections: 0,
                                             monthMap: [:], totalDays: 0))
            }
            // Set the new cache
            cachedConfiguration = validConfig
            if let
                startMonth = Date.startOfMonth(for: validConfig.startDate,
                                               using: validConfig.calendar),
                let endMonth = Date.endOfMonth(for: validConfig.endDate,
                                               using: validConfig.calendar) {
                startOfMonthCache = startMonth
                endOfMonthCache   = endMonth
                // Create the parameters for the date format generator
                let parameters = DateConfigParameters(
                    inCellGeneration: validConfig.generateInDates,
                    outCellGeneration: validConfig.generateOutDates,
                    numberOfRows: validConfig.numberOfRows,
                    startOfMonthCache: startOfMonthCache,
                    endOfMonthCache: endOfMonthCache,
                    configuredCalendar: validConfig.calendar,
                    firstDayOfWeek: validConfig.firstDayOfWeek)
                let generatedData = dateGenerator
                    .setupMonthInfoDataForStartAndEndDate(parameters)
                months = generatedData.months
                monthMap = generatedData.monthMap
                totalSections = generatedData.totalSections
                totalDays = generatedData.totalDays
            }
        }
        let data = CalendarData(months: months, totalSections: totalSections,
                                monthMap: monthMap, totalDays: totalDays)
        return data
    }

    func pathsFromDates(_ dates: [Date]) -> [IndexPath] {
        var returnPaths: [IndexPath] = []
        for date in dates {
            if  calendar.startOfDay(for: date) >= startOfMonthCache &&
                        calendar.startOfDay(for: date) <= endOfMonthCache {
                if  calendar.startOfDay(for: date) >= startOfMonthCache &&
                        calendar.startOfDay(for: date) <= endOfMonthCache {

                    let periodApart = calendar.dateComponents([.month],
                                        from: startOfMonthCache, to: date)
                    let day = calendar.dateComponents([.day], from: date).day!
                    let monthSectionIndex = periodApart.month
                    let currentMonthInfo = monthInfo[monthSectionIndex!]
                    if let indexPath = currentMonthInfo
                        .indexPath(forDay: day) {
                            returnPaths.append(indexPath)
                    }
                }
            }
        }
        return returnPaths
    }

    func cellStateFromIndexPath(_ indexPath: IndexPath,
                withDateInfo info: (date: Date, owner: DateOwner)? = nil,
                cell: JTAppleDayCell? = nil) -> CellState {
        let validDateInfo: (date: Date, owner: DateOwner)
        if let nonNilDateInfo = info {
            validDateInfo = nonNilDateInfo
        } else {
            guard let newDateInfo = dateInfoFromPath(indexPath) else {
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
                                    return (range: (Date(), Date()),
                                            month: 0, rowsForSection: 0)
                                 },
                                 selectedPosition: {return .left},
                                 cell: {return nil})
            }
            validDateInfo = newDateInfo
        }
        let date = validDateInfo.date
        let dateBelongsTo = validDateInfo.owner
        let currentDay = calendar.dateComponents([.day], from: date).day!
        let componentWeekDay = calendar.component(.weekday, from: date)
        let cellText = String(describing: currentDay)
        let dayOfWeek = DaysOfWeek(rawValue: componentWeekDay)!
        let rangePosition = { () -> SelectionRangePosition in
            if self.theSelectedIndexPaths.contains(indexPath) {
                if self.selectedDates.count == 1 {
                    return .full
                }
                let left = self.theSelectedIndexPaths
                    .contains(IndexPath(item: indexPath.item - 1,
                                        section: indexPath.section))
                let right = self.theSelectedIndexPaths
                    .contains(IndexPath(item: indexPath.item + 1,
                                        section: indexPath.section))
                if left == right {
                    if left == false {
                        return .full
                    } else {
                        return .middle
                    }
                } else {
                    if left == false {
                        return .left
                    } else {
                        return .right
                    }
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
            row: { return indexPath.item / maxNumberOfDaysInWeek },
            column: { return indexPath.item % maxNumberOfDaysInWeek },
            dateSection: {
                return self.monthInfoFromSection(indexPath.section)!
            },
            selectedPosition: rangePosition,
            cell: {return cell}
        )
        return cellState
    }

    func batchReloadIndexPaths(_ indexPaths: [IndexPath]) {
        if indexPaths.count < 1 {
            return
        }
        UICollectionView.performWithoutAnimation {
            self.calendarView.performBatchUpdates({
                self.calendarView.reloadItems(at: indexPaths)
                }, completion: nil)
        }
    }

    func addCellToSelectedSetIfUnselected(_ indexPath: IndexPath,
                                          date: Date) {
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

    func deselectCounterPartCellIndexPath(_ indexPath: IndexPath,
                        date: Date, dateOwner: DateOwner) -> IndexPath? {
        if let counterPartCellIndexPath =
            indexPathOfdateCellCounterPart(date, indexPath: indexPath,
                                           dateOwner: dateOwner) {
            deleteCellFromSelectedSetIfSelected(counterPartCellIndexPath)
            return counterPartCellIndexPath
        }
        return nil
    }

    func selectCounterPartCellIndexPathIfExists(_ indexPath: IndexPath,
                            date: Date, dateOwner: DateOwner) -> IndexPath? {
        if let counterPartCellIndexPath =
                indexPathOfdateCellCounterPart(date, indexPath: indexPath,
                                               dateOwner: dateOwner) {
            let dateComps = calendar
                .dateComponents([.month, .day, .year], from: date)
            guard let counterpartDate = calendar
                .date(from: dateComps) else { return nil }
            addCellToSelectedSetIfUnselected(counterPartCellIndexPath,
                                             date: counterpartDate)
            return counterPartCellIndexPath
        }
        return nil
    }

    func monthInfoFromSection(_ section: Int) ->
        (range: (start: Date, end: Date), month: Int, rowsForSection: Int)? {
            let monthIndex = monthMap[section]!
            let monthData = monthInfo[monthIndex]
            let startIndex = monthData.preDates
            let endIndex = monthData.numberOfDaysInMonth + startIndex - 1
            let startIndexPath = IndexPath(item: startIndex, section: section)
            let endIndexPath = IndexPath(item: endIndex, section: section)
            guard let
                startDate = dateInfoFromPath(startIndexPath)?.date,
                let endDate = dateInfoFromPath(endIndexPath)?.date else {
                    return nil
            }
            if let monthDate = calendar.date(byAdding: .month,
                                             value: monthIndex,
                                             to: startDateCache) {
                let monthNumber = calendar.dateComponents([.month],
                                                          from: monthDate)
                let numberOfRowsForSection =
                    monthData.numberOfRows(for: section,
                                           developerSetRows: numberOfRows())
                return ((startDate, endDate),
                        monthNumber.month!,
                        numberOfRowsForSection)
            }
            return nil
    }

    func dateInfoFromPath(_ indexPath: IndexPath) -> (date: Date,
                                                     owner: DateOwner)? {
                                   // Returns nil if date is out of scope
        guard let monthIndex = monthMap[indexPath.section] else {
            return nil
        }
        let monthData = monthInfo[monthIndex]
        let offSet: Int
        var numberOfDaysToAddToOffset: Int = 0
        switch monthData.sectionIndexMaps[indexPath.section]! {
        case 0:
            offSet = monthData.preDates
        default:
            offSet = 0
            let currentSectionIndexMap =
                monthData.sectionIndexMaps[indexPath.section]!
            numberOfDaysToAddToOffset =
                monthData.sections[0..<currentSectionIndexMap].reduce(0, +)
            numberOfDaysToAddToOffset -= monthData.preDates
        }
        var dayIndex = 0
        var dateOwner: DateOwner = .thisMonth
        let date: Date?
        var dateComponents = DateComponents()
        if indexPath.item >= offSet && indexPath.item +
            numberOfDaysToAddToOffset <
            monthData.numberOfDaysInMonth + offSet {
            // This is a month date
            dayIndex = monthData.startDayIndex +
                indexPath.item - offSet + numberOfDaysToAddToOffset
            dateComponents.day = dayIndex
            date = calendar.date(byAdding: dateComponents,
                                 to: startOfMonthCache)
            dateOwner = .thisMonth
        } else if indexPath.item < offSet {
            // This is a preDate
            dayIndex = indexPath.item - offSet  + monthData.startDayIndex
            dateComponents.day = dayIndex
            date = calendar.date(byAdding: dateComponents,
                                 to: startOfMonthCache)
            if date! < startOfMonthCache {
                dateOwner = .previousMonthOutsideBoundary
            } else {
                dateOwner = .previousMonthWithinBoundary
            }
        } else {
            // This is a postDate
            dayIndex =  monthData.startDayIndex - offSet +
                indexPath.item + numberOfDaysToAddToOffset
            dateComponents.day = dayIndex
            date = calendar.date(byAdding: dateComponents,
                                 to: startOfMonthCache)
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
