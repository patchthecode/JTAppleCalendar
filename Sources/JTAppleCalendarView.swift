//
//  JTAppleCalendarView.swift
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

let maxNumberOfDaysInWeek = 7 // Should not be changed
let maxNumberOfRowsPerMonth = 6 // Should not be changed
let developerErrorMessage = "There was an error in this code section. Please contact the developer on GitHub"
let decorationViewID = "Are you ready for the life after this one?"


/// An instance of JTAppleCalendarView (or simply, a calendar view) is a
/// means for displaying and interacting with a gridstyle layout of date-cells
open class JTAppleCalendarView: UICollectionView {
    
    /// Configures the size of your date cells
    @IBInspectable open var cellSize: CGFloat = 0 {
        didSet {
            if oldValue == cellSize { return }
            if scrollDirection == .horizontal {
                calendarViewLayout.cellSize.width = cellSize
            } else {
                calendarViewLayout.cellSize.height = cellSize
            }
            calendarViewLayout.invalidateLayout()
            calendarViewLayout.itemSizeWasSet = cellSize == 0 ? false: true
        }
    }
    
    /// The scroll direction of the sections in JTAppleCalendar.
    open var scrollDirection: UICollectionViewScrollDirection!
    
    /// Enables/Disables the stretching of date cells. When enabled cells will stretch to fit the width of a month in case of a <= 5 row month.
    open var allowsDateCellStretching = true
    
    /// Alerts the calendar that range selection will be checked. If you are
    /// not using rangeSelection and you enable this,
    /// then whenever you click on a datecell, you may notice a very fast
    /// refreshing of the date-cells both left and right of the cell you
    /// just selected.
    open var isRangeSelectionUsed: Bool = false
    
    /// The object that acts as the delegate of the calendar view.
    weak open var calendarDelegate: JTAppleCalendarViewDelegate? {
        didSet { lastMonthSize = sizesForMonthSection() }
    }
    
    /// The object that acts as the data source of the calendar view.
    weak open var calendarDataSource: JTAppleCalendarViewDataSource? {
        didSet { setupMonthInfoAndMap() } // Refetch the data source for a data source change
    }
    
    var lastSavedContentOffset: CGFloat    = 0.0
    var triggerScrollToDateDelegate: Bool? = true
    var isScrollInProgress                 = false
    var isReloadDataInProgress             = false
    
    // keeps track of if didEndScroll is not yet completed. If isStillScrolling
    var didEndScollCount = 0
    // Keeps track of scroll target location. If isScrolling, and user taps while scrolling
    var endScrollTargetLocation: CGFloat = 0
    
    
    var generalDelayedExecutionClosure: [(() -> Void)] = []
    var scrollDelayedExecutionClosure: [(() -> Void)]  = []
    
    let dateGenerator = JTAppleDateConfigGenerator()
    
    /// Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
    public init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        setupNewLayout(from: collectionViewLayout as! JTAppleCalendarLayoutProtocol)
    }
    
    /// Initializes and returns a newly allocated collection view object with the specified frame and layout.
    @available(*, unavailable, message: "Please use JTAppleCalendarView() instead. It manages its own layout.")
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        setupNewLayout(from: collectionViewLayout as! JTAppleCalendarLayoutProtocol)
    }
    
    /// Initializes using decoder object
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNewLayout(from: collectionViewLayout as! JTAppleCalendarLayoutProtocol)
    }
    
    /// Lays out subviews.
    override open func layoutSubviews() {
        super.layoutSubviews()
        if !generalDelayedExecutionClosure.isEmpty, isCalendarLayoutLoaded {
            executeDelayedTasks(.general)
        }
    }
    
    func setupMonthInfoAndMap(with data: ConfigurationParameters? = nil) {
        theData = setupMonthInfoDataForStartAndEndDate(with: data)
    }
    
    // Configuration parameters from the dataSource
    var cachedConfiguration: ConfigurationParameters!
    // Set the start of the month
    var startOfMonthCache: Date!
    // Set the end of month
    var endOfMonthCache: Date!
    var selectedCellData: [IndexPath:SelectedCellData] = [:]
    var pathsToReload: Set<IndexPath> = [] //Paths to reload because of prefetched cells
    
    var anchorDate: Date?
    
    var firstContentOffset: CGPoint {
        var retval: CGPoint = .zero
        guard let date = anchorDate else { return retval }
        
        // reset the initial scroll date once used.
        anchorDate = nil
        
        // Ensure date is within valid boundary
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let firstDayOfDate = calendar.date(from: components)!
        if !((firstDayOfDate >= self.startOfMonthCache!) && (firstDayOfDate <= self.endOfMonthCache!)) { return retval }
        
        // Get valid indexPath of date to scroll to
        let retrievedPathsFromDates = self.pathsFromDates([date])
        if retrievedPathsFromDates.isEmpty { return retval }
        let sectionIndexPath =  self.pathsFromDates([date])[0]
        
        
        if calendarViewLayout.thereAreHeaders && scrollDirection == .vertical {
            let indexPath = IndexPath(item: 0, section: sectionIndexPath.section)
            guard let attributes = calendarViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath) else { return retval }
            
            let maxYCalendarOffset = max(0, self.contentSize.height - self.frame.size.height)
            retval = CGPoint(x: attributes.frame.origin.x,y: min(maxYCalendarOffset, attributes.frame.origin.y))
            //            if self.scrollDirection == .horizontal { topOfHeader.x += extraAddedOffset} else { topOfHeader.y += extraAddedOffset }
            
        } else {
            switch self.scrollingMode {
            case .stopAtEach, .stopAtEachSection, .stopAtEachCalendarFrame:
                if self.scrollDirection == .horizontal || (scrollDirection == .vertical && !calendarViewLayout.thereAreHeaders) {
                    retval = self.targetPointForItemAt(indexPath: sectionIndexPath) ?? .zero
                }
            default:
                break
            }
        }
        return retval
    }
    
    open var sectionInset: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    open var minimumInteritemSpacing: CGFloat = 0
    open var minimumLineSpacing: CGFloat = 0
    
    lazy var theData: CalendarData = {
        return self.setupMonthInfoDataForStartAndEndDate()
    }()
    
    var lastMonthSize: [AnyHashable:CGFloat] = [:]
    
    var monthMap: [Int: Int] {
        get { return theData.sectionToMonthMap }
        set { theData.sectionToMonthMap = monthMap }
    }
    
    /// Configure the scrolling behavior
    open var scrollingMode: ScrollingMode = .stopAtEachCalendarFrame {
        didSet {
            switch scrollingMode {
            case .stopAtEachCalendarFrame: decelerationRate = UIScrollViewDecelerationRateFast
            case .stopAtEach, .stopAtEachSection: decelerationRate = UIScrollViewDecelerationRateFast
            case .nonStopToSection, .nonStopToCell, .nonStopTo, .none: decelerationRate = UIScrollViewDecelerationRateNormal
            }
            #if os(iOS)
                switch scrollingMode {
                case .stopAtEachCalendarFrame:
                    isPagingEnabled = true
                default:
                    isPagingEnabled = false
                }
            #endif
        }
    }
    
    func developerError(string: String) {
        print(string)
        print(developerErrorMessage)
        assert(false)
    }
    
    
    func setupNewLayout(from oldLayout: JTAppleCalendarLayoutProtocol) {
        
        let newLayout = JTAppleCalendarLayout(withDelegate: self)
        newLayout.scrollDirection = oldLayout.scrollDirection
        newLayout.sectionInset = oldLayout.sectionInset
        newLayout.minimumInteritemSpacing = oldLayout.minimumInteritemSpacing
        newLayout.minimumLineSpacing = oldLayout.minimumLineSpacing
        
        
        collectionViewLayout = newLayout
        
        scrollDirection = newLayout.scrollDirection
        sectionInset = newLayout.sectionInset
        minimumLineSpacing = newLayout.minimumLineSpacing
        minimumInteritemSpacing = newLayout.minimumInteritemSpacing
        
        
        if #available(iOS 9.0, *) {
            transform.a = semanticContentAttribute == .forceRightToLeft ? -1 : 1
        }
        
        super.dataSource = self
        super.delegate = self
        decelerationRate = UIScrollViewDecelerationRateFast
        
        #if os(iOS)
            if isPagingEnabled {
                scrollingMode = .stopAtEachCalendarFrame
            } else {
                scrollingMode = .none
            }
        #endif
    }
    
    func validForwardAndBackwordSelectedIndexes(forIndexPath indexPath: IndexPath) -> Set<IndexPath> {
        var retval: Set<IndexPath> = []
        if let validForwardIndex = calendarViewLayout.indexPath(direction: .next, of: indexPath.section, item: indexPath.item),
            validForwardIndex.section == indexPath.section,
            selectedCellData[validForwardIndex] != nil {
            retval.insert(validForwardIndex)
        }
        if
            let validBackwardIndex = calendarViewLayout.indexPath(direction: .previous, of: indexPath.section, item: indexPath.item),
            validBackwardIndex.section == indexPath.section,
            selectedCellData[validBackwardIndex] != nil {
            retval.insert(validBackwardIndex)
        }
        return retval
    }
    
    func scrollTo(indexPath: IndexPath, triggerScrollToDateDelegate: Bool, isAnimationEnabled: Bool, position: UICollectionViewScrollPosition, extraAddedOffset: CGFloat, completionHandler: (() -> Void)?) {
        isScrollInProgress = true
        if let validCompletionHandler = completionHandler { self.scrollDelayedExecutionClosure.append(validCompletionHandler) }
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        DispatchQueue.main.async {
            self.scrollToItem(at: indexPath, at: position, animated: isAnimationEnabled)
            if (isAnimationEnabled && self.calendarOffsetIsAlreadyAtScrollPosition(forIndexPath: indexPath)) ||
                !isAnimationEnabled {
                self.scrollViewDidEndScrollingAnimation(self)
            }
            self.isScrollInProgress = false
        }
    }
    
    func targetPointForItemAt(indexPath: IndexPath) -> CGPoint? {
        guard let targetCellFrame = calendarViewLayout.layoutAttributesForItem(at: indexPath)?.frame else { // Jt101 This was changed !!
            return nil
        }
        
        let theTargetContentOffset: CGFloat = scrollDirection == .horizontal ? targetCellFrame.origin.x : targetCellFrame.origin.y
        var fixedScrollSize: CGFloat = 0
        switch scrollingMode {
        case .stopAtEachSection, .stopAtEachCalendarFrame, .nonStopToSection:
            if self.scrollDirection == .horizontal || (scrollDirection == .vertical && !calendarViewLayout.thereAreHeaders) {
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
        let divValue = scrollDirection == .horizontal ? frame.width : frame.height
        let sectionForOffset = Int(theOffset / divValue)
        let calendarCurrentOffset = scrollDirection == .horizontal ? contentOffset.x : contentOffset.y
        if calendarCurrentOffset == theOffset || (scrollingMode.pagingIsEnabled() && (sectionForOffset ==  currentSection())) {
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
        if let attributes = calendarViewLayout.layoutAttributesForItem(at: indexPath) { // JT101 this was changed!!!!
            let layoutOffset: CGFloat
            let calendarOffset: CGFloat
            if scrollDirection == .horizontal {
                layoutOffset = attributes.frame.origin.x
                calendarOffset = contentOffset.x
            } else {
                layoutOffset = attributes.frame.origin.y
                calendarOffset = contentOffset.y
            }
            if  calendarOffset == layoutOffset {
                retval = true
            }
        }
        return retval
    }
    
    func scrollToHeaderInSection(_ section: Int,
                                 triggerScrollToDateDelegate: Bool = false,
                                 withAnimation animation: Bool = true,
                                 extraAddedOffset: CGFloat,
                                 completionHandler: (() -> Void)? = nil) {
        if !calendarViewLayout.thereAreHeaders { return }
        let indexPath = IndexPath(item: 0, section: section)
        guard let attributes = calendarViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath) else { return }
        
        isScrollInProgress = true
        if let validHandler = completionHandler { scrollDelayedExecutionClosure.append(validHandler) }
        
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        
        let maxYCalendarOffset = max(0, self.contentSize.height - self.frame.size.height)
        var topOfHeader = CGPoint(x: attributes.frame.origin.x,y: min(maxYCalendarOffset, attributes.frame.origin.y))
        if self.scrollDirection == .horizontal { topOfHeader.x += extraAddedOffset} else { topOfHeader.y += extraAddedOffset }
        DispatchQueue.main.async {
            self.setContentOffset(topOfHeader, animated: animation)
            if (animation && self.calendarOffsetIsAlreadyAtScrollPosition(forOffset: topOfHeader)) ||
                !animation {
                self.scrollViewDidEndScrollingAnimation(self)
            }
            self.isScrollInProgress = false
        }
    }
    
    // Subclasses cannot use this function
    @available(*, unavailable)
    open override func reloadData() {
        super.reloadData()
    }
    
    
    func executeDelayedTasks(_ type: DelayedTaskType) {
        let tasksToExecute: [(() -> Void)]
        switch type {
        case .scroll:
            tasksToExecute = scrollDelayedExecutionClosure
            scrollDelayedExecutionClosure.removeAll()
        case .general:
            tasksToExecute = generalDelayedExecutionClosure
            generalDelayedExecutionClosure.removeAll()
        }
        for aTaskToExecute in tasksToExecute { aTaskToExecute() }
    }
    
    // Only reload the dates if the datasource information has changed
    func reloadDelegateDataSource() -> (shouldReload: Bool, configParameters: ConfigurationParameters?) {
        var retval: (Bool, ConfigurationParameters?) = (false, nil)
        if let
            newDateBoundary = calendarDataSource?.configureCalendar(self) {
            // Jt101 do a check in each var to see if
            // user has bad star/end dates
            let newStartOfMonth = calendar.startOfMonth(for: newDateBoundary.startDate)
            let newEndOfMonth   = calendar.endOfMonth(for: newDateBoundary.endDate)
            let oldStartOfMonth = calendar.startOfMonth(for: startDateCache)
            let oldEndOfMonth   = calendar.endOfMonth(for: endDateCache)
            let newLastMonth    = sizesForMonthSection()
            let calendarLayout  = calendarViewLayout
            
            if
                // ConfigParameters were changed
                newStartOfMonth                     != oldStartOfMonth ||
                    newEndOfMonth                       != oldEndOfMonth ||
                    newDateBoundary.calendar            != cachedConfiguration.calendar ||
                    newDateBoundary.numberOfRows        != cachedConfiguration.numberOfRows ||
                    newDateBoundary.generateInDates     != cachedConfiguration.generateInDates ||
                    newDateBoundary.generateOutDates    != cachedConfiguration.generateOutDates ||
                    newDateBoundary.firstDayOfWeek      != cachedConfiguration.firstDayOfWeek ||
                    newDateBoundary.hasStrictBoundaries != cachedConfiguration.hasStrictBoundaries ||
                    // Other layout information were changed
                    minimumInteritemSpacing  != calendarLayout.minimumInteritemSpacing ||
                    minimumLineSpacing       != calendarLayout.minimumLineSpacing ||
                    sectionInset             != calendarLayout.sectionInset ||
                    lastMonthSize            != newLastMonth ||
                    allowsDateCellStretching != calendarLayout.allowsDateCellStretching ||
                    scrollDirection          != calendarLayout.scrollDirection ||
                    calendarLayout.cellSizeWasUpdated {
                lastMonthSize = newLastMonth
                retval = (true, newDateBoundary)
            }
        }
        
        return retval
    }
    
    func remapSelectedDatesWithCurrentLayout() -> (selected:(indexPaths:[IndexPath], counterPaths:[IndexPath]), selectedDates: [Date]) {
        var retval = (selected:(indexPaths:[IndexPath](), counterPaths:[IndexPath]()), selectedDates: [Date]())
        if !selectedDates.isEmpty {
            let selectedDates = self.selectedDates
            
            // Get the new paths
            let newPaths = self.pathsFromDates(selectedDates)
            
            // Get the new counter Paths
            var newCounterPaths: [IndexPath] = []
            for date in selectedDates {
                if let counterPath = self.indexPathOfdateCellCounterPath(date, dateOwner: .thisMonth) {
                    newCounterPaths.append(counterPath)
                }
            }
            
            // Append paths
            retval.selected.indexPaths.append(contentsOf: newPaths)
            retval.selected.counterPaths.append(contentsOf: newCounterPaths)
            
            // Append dates to retval
            for allPaths in [newPaths, newCounterPaths] {
                for path in allPaths {
                    guard let dateFromPath = dateOwnerInfoFromPath(path)?.date else { continue }
                    retval.selectedDates.append(dateFromPath)
                }
            }
            
        }
        return retval
    }
}

@available(iOS 9.0, *)
extension JTAppleCalendarView {
    /// A semantic description of the view’s contents, used to determine whether the view should be flipped when switching between left-to-right and right-to-left layouts.
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            transform.a = semanticContentAttribute == .forceRightToLeft ? -1 : 1
        }
    }
}

extension JTAppleCalendarView {
    
    func handleScroll(point: CGPoint? = nil,
                      indexPath: IndexPath? = nil,
                      triggerScrollToDateDelegate: Bool = true,
                      isAnimationEnabled: Bool,
                      position: UICollectionViewScrollPosition? = .left,
                      extraAddedOffset: CGFloat = 0,
                      completionHandler: (() -> Void)?) {
        
        if isScrollInProgress { return }
        
        // point takes preference
        if let validPoint = point {
            scrollTo(point: validPoint,
                     triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                     isAnimationEnabled: isAnimationEnabled,
                     extraAddedOffset: extraAddedOffset,
                     completionHandler: completionHandler)
        } else {
            guard let validIndexPath = indexPath else { return }
            
            var isNonConinuousScroll = true
            switch scrollingMode {
            case .none, .nonStopToCell: isNonConinuousScroll = false
            default: break
            }
            
            if calendarViewLayout.thereAreHeaders,
                scrollDirection == .vertical,
                isNonConinuousScroll {
                scrollToHeaderInSection(validIndexPath.section,
                                        triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                                        withAnimation: isAnimationEnabled,
                                        extraAddedOffset: extraAddedOffset,
                                        completionHandler: completionHandler)
            } else {
                scrollTo(indexPath:validIndexPath,
                         triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                         isAnimationEnabled: isAnimationEnabled,
                         position: position ?? .left,
                         extraAddedOffset: extraAddedOffset,
                         completionHandler: completionHandler)
            }
        }
    }
    
    func scrollTo(point: CGPoint, triggerScrollToDateDelegate: Bool? = nil, isAnimationEnabled: Bool, extraAddedOffset: CGFloat, completionHandler: (() -> Void)?) {
        isScrollInProgress = true
        if let validCompletionHandler = completionHandler { scrollDelayedExecutionClosure.append(validCompletionHandler) }
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        var point = point
        if scrollDirection == .horizontal { point.x += extraAddedOffset } else { point.y += extraAddedOffset }
        DispatchQueue.main.async() {
            self.setContentOffset(point, animated: isAnimationEnabled)
            if (isAnimationEnabled && self.calendarOffsetIsAlreadyAtScrollPosition(forOffset: point)) ||
                !isAnimationEnabled {
                self.scrollViewDidEndScrollingAnimation(self)
            }
            self.isScrollInProgress = false
        }
    }
    
    func indexPathOfdateCellCounterPath(_ date: Date,
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
            guard let dayIndex = calendar.dateComponents([.day], from: date).day else {
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
                        assert(false, "Error generating date in indexPathOfdateCellCounterPath(). Contact the developer on github")
                        return retval
                }
                
                let indexPathOfLastDayOfPreviousMonth = pathsFromDates([lastDayOfPrevMonth])
                if indexPathOfLastDayOfPreviousMonth.isEmpty {
                    print("out of range error in indexPathOfdateCellCounterPath() upper. This should not happen. Contact developer on github")
                    return retval
                }
                let lastDayIndexPath = indexPathOfLastDayOfPreviousMonth[0]
                var section = lastDayIndexPath.section
                var itemIndex = lastDayIndexPath.item + dayIndex
                // Determine if the sections/item needs to be adjusted
                
                let extraSection = itemIndex / collectionView(self, numberOfItemsInSection: section)
                let extraIndex = itemIndex % collectionView(self, numberOfItemsInSection: section)
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
    
    func setupMonthInfoDataForStartAndEndDate(with config: ConfigurationParameters? = nil) -> CalendarData {
        var months = [Month]()
        var monthMap = [Int: Int]()
        var totalSections = 0
        var totalDays = 0
        
        var validConfig = config
        if validConfig == nil { validConfig = calendarDataSource?.configureCalendar(self) }
        if let validConfig = validConfig {
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
    
    func sizesForMonthSection() -> [AnyHashable:CGFloat] {
        var retval: [AnyHashable:CGFloat] = [:]
        guard
            let headerSizes = calendarDelegate?.calendarSizeForMonths(self),
            headerSizes.defaultSize > 0 else {
                return retval
        }
        
        // Build the default
        retval["default"] = headerSizes.defaultSize
        
        // Build the every-month data
        if let allMonths = headerSizes.months {
            for (size, months) in allMonths {
                for month in months {
                    assert(retval[month] == nil, "You have duplicated months. Please revise your month size data.")
                    retval[month] = size
                }
            }
        }
        
        // Build the specific month data
        if let specificSections = headerSizes.dates {
            for (size, dateArray) in specificSections {
                let paths = pathsFromDates(dateArray)
                for path in paths {
                    retval[path.section] = size
                }
            }
        }
        return retval
    }
    
    func pathsFromDates(_ dates: [Date]) -> [IndexPath] {
        var returnPaths: [IndexPath] = []
        for date in dates {
            if calendar.startOfDay(for: date) >= startOfMonthCache! && calendar.startOfDay(for: date) <= endOfMonthCache! {
                let periodApart = calendar.dateComponents([.month], from: startOfMonthCache, to: date)
                let day = calendar.dateComponents([.day], from: date).day!
                guard let monthSectionIndex = periodApart.month else { continue }
                let currentMonthInfo = monthInfo[monthSectionIndex]
                if let indexPath = currentMonthInfo.indexPath(forDay: day) {
                    returnPaths.append(indexPath)
                }
            }
        }
        return returnPaths
    }
    
    func cellStateFromIndexPath(_ indexPath: IndexPath,
                                withDateInfo info: (date: Date, owner: DateOwner)? = nil,
                                cell: JTAppleCell? = nil,
                                isSelected: Bool? = nil,
                                selectionType: SelectionType? = nil) -> CellState {
        let validDateInfo: (date: Date, owner: DateOwner)
        if let nonNilDateInfo = info {
            validDateInfo = nonNilDateInfo
        } else {
            guard let newDateInfo = dateOwnerInfoFromPath(indexPath) else {
                developerError(string: "Error this should not be nil. Contact developer Jay on github by opening a request")
                return CellState(isSelected: false,
                                 text: "",
                                 dateBelongsTo: .thisMonth,
                                 date: Date(),
                                 day: .sunday,
                                 row: { return 0 },
                                 column: { return 0 },
                                 dateSection: { return (range: (Date(), Date()), month: 0, rowCount: 0) },
                                 selectedPosition: {return .left},
                                 cell: {return nil},
                                 selectionType: nil)
            }
            validDateInfo = newDateInfo
        }
        let date = validDateInfo.date
        let dateBelongsTo = validDateInfo.owner
        
        let currentDay = calendar.component(.day, from: date)
        let componentWeekDay = calendar.component(.weekday, from: date)
        let cellText = String(describing: currentDay)
        let dayOfWeek = DaysOfWeek(rawValue: componentWeekDay)!
        
        let selectedPosition = { [unowned self] () -> SelectionRangePosition in
            let selectedDates = self.selectedDatesSet
            if !selectedDates.contains(date) || selectedDates.isEmpty  { return .none }
            
            let dateBefore = self.cachedConfiguration.calendar.date(byAdding: .day, value: 1, to: date)!
            let dateAfter = self.cachedConfiguration.calendar.date(byAdding: .day, value: -1, to: date)!
            
            let dateBeforeIsSelected = selectedDates.contains(dateBefore)
            let dateAfterIsSelected = selectedDates.contains(dateAfter)
            
            var position: SelectionRangePosition
            
            if dateBeforeIsSelected, dateAfterIsSelected {
                position = .middle
            } else if !dateBeforeIsSelected, dateAfterIsSelected {
                position = .left
            } else if dateBeforeIsSelected, !dateAfterIsSelected {
                position = .right
            } else if !dateBeforeIsSelected, !dateAfterIsSelected  {
                position = .full
            } else {
                position = .none
            }
            return position
        }
        
        let cellState = CellState(
            isSelected: isSelected ?? (selectedCellData[indexPath] != nil),
            text: cellText,
            dateBelongsTo: dateBelongsTo,
            date: date,
            day: dayOfWeek,
            row: { return indexPath.item / maxNumberOfDaysInWeek },
            column: { return indexPath.item % maxNumberOfDaysInWeek },
            dateSection: { [unowned self] in
                return self.monthInfoFromSection(indexPath.section)!
        },
            selectedPosition: selectedPosition,
            cell: { return cell },
            selectionType: selectionType
        )
        return cellState
    }
    
    func batchReloadIndexPaths(_ indexPaths: [IndexPath]) {
        let visiblePaths = indexPathsForVisibleItems
        var visibleCellsToReload: [JTAppleCell: IndexPath] = [:]
        
        for path in indexPaths {
            if calendarViewLayout.cachedValue(for: path.item, section: path.section) == nil { continue }
            pathsToReload.insert(path)
            if visiblePaths.contains(path) {
                visibleCellsToReload[cellForItem(at: path) as! JTAppleCell] = path
            }
        }
        
        // Reload the visible paths
        if !visibleCellsToReload.isEmpty {
            for (cell, path) in visibleCellsToReload {
                self.collectionView(self, willDisplay: cell, forItemAt: path)
            }
        }
    }
    
    func addCellToSelectedSet(_ indexPath: IndexPath, date: Date, cellState: CellState) {
        selectedCellData[indexPath] = SelectedCellData(indexPath: indexPath, date: date, cellState: cellState)
    }
    
    func deleteCellFromSelectedSetIfSelected(_ indexPath: IndexPath) {
        selectedCellData.removeValue(forKey: indexPath)
    }
    
    // Returns an indexPath if valid one was found
    func deselectCounterPartCellIndexPath(_ indexPath: IndexPath, date: Date, dateOwner: DateOwner) -> IndexPath? {
        guard let counterPartCellIndexPath = indexPathOfdateCellCounterPath(date, dateOwner: dateOwner) else { return nil }
        deleteCellFromSelectedSetIfSelected(counterPartCellIndexPath)
        deselectItem(at: counterPartCellIndexPath, animated: false)
        return counterPartCellIndexPath
    }
    
    func selectCounterPartCellIndexPath(_ indexPath: IndexPath, date: Date, dateOwner: DateOwner) -> IndexPath? {
        guard let counterPartCellIndexPath = indexPathOfdateCellCounterPath(date, dateOwner: dateOwner) else { return nil }
        let counterPartCellState = cellStateFromIndexPath(counterPartCellIndexPath, isSelected: true)
        addCellToSelectedSet(counterPartCellIndexPath, date: date, cellState: counterPartCellState)
        
        // Update the selectedCellData counterIndexPathData
        selectedCellData[indexPath]?.counterIndexPath = counterPartCellIndexPath
        selectedCellData[counterPartCellIndexPath]?.counterIndexPath = indexPath
        
        if allowsMultipleSelection {
            // only if multiple selection is enabled. With single selection, we do not want the counterpart cell to be
            // selected in place of the main cell. With multiselection, however, all can be selected
            selectItem(at: counterPartCellIndexPath, animated: false, scrollPosition: [])
        }
        return counterPartCellIndexPath
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
            let numberOfRowsForSection = monthData.numberOfRows(for: section, developerSetRows: cachedConfiguration.numberOfRows)
            return ((startDate, endDate), monthNumber.month!, numberOfRowsForSection)
        }
        return nil
    }
    
    /// Retrieves the current section
    public func currentSection() -> Int? {
        let minVisiblePaths = calendarViewLayout.minimumVisibleIndexPaths()
        return minVisiblePaths.cellIndex?.section
    }
    
    func dateSegmentInfoFrom(visible indexPaths: [IndexPath]) -> DateSegmentInfo {
        var inDates    = [(Date, IndexPath)]()
        var monthDates = [(Date, IndexPath)]()
        var outDates   = [(Date, IndexPath)]()
        
        for indexPath in indexPaths {
            let info = dateOwnerInfoFromPath(indexPath)
            if let validInfo = info  {
                switch validInfo.owner {
                case .thisMonth:
                    monthDates.append((validInfo.date, indexPath))
                case .previousMonthWithinBoundary, .previousMonthOutsideBoundary:
                    inDates.append((validInfo.date, indexPath))                    
                default:
                    outDates.append((validInfo.date, indexPath))
                }
            }
        }
        
        let retval = DateSegmentInfo(indates: inDates, monthDates: monthDates, outdates: outDates)
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
