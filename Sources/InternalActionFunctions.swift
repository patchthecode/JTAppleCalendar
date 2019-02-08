//
//  InternalActionFunctions.swift
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

extension JTAppleCalendarView {
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
        decelerationRate = .fast
        
        #if os(iOS)
            if isPagingEnabled {
                scrollingMode = .stopAtEachCalendarFrame
            } else {
                scrollingMode = .none
            }
        #endif
    }
    
    func scrollTo(indexPath: IndexPath, triggerScrollToDateDelegate: Bool, isAnimationEnabled: Bool, position: UICollectionView.ScrollPosition, extraAddedOffset: CGFloat, completionHandler: (() -> Void)?) {
        isScrollInProgress = true
        if let validCompletionHandler = completionHandler { scrollDelayedExecutionClosure.append(validCompletionHandler) }
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
    
    func scrollToHeaderInSection(_ section: Int,
                                 triggerScrollToDateDelegate: Bool = false,
                                 withAnimation animation: Bool = true,
                                 extraAddedOffset: CGFloat,
                                 completionHandler: (() -> Void)? = nil) {
        if !calendarViewLayout.thereAreHeaders { return }
        let indexPath = IndexPath(item: 0, section: section)
        guard let attributes = calendarViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) else { return }
        
        isScrollInProgress = true
        if let validHandler = completionHandler { scrollDelayedExecutionClosure.append(validHandler) }
        
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        
        let maxYCalendarOffset = max(0, self.contentSize.height - self.frame.size.height)
        var topOfHeader = CGPoint(x: attributes.frame.origin.x,y: min(maxYCalendarOffset, attributes.frame.origin.y))
        if scrollDirection == .horizontal { topOfHeader.x += extraAddedOffset} else { topOfHeader.y += extraAddedOffset }
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
    
    func handleScroll(point: CGPoint? = nil,
                      indexPath: IndexPath? = nil,
                      triggerScrollToDateDelegate: Bool = true,
                      isAnimationEnabled: Bool,
                      position: UICollectionView.ScrollPosition? = .left,
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
        }
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
            _cachedConfiguration = validConfig
            
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
                newDateBoundary.calendar            != _cachedConfiguration.calendar ||
                newDateBoundary.numberOfRows        != _cachedConfiguration.numberOfRows ||
                newDateBoundary.generateInDates     != _cachedConfiguration.generateInDates ||
                newDateBoundary.generateOutDates    != _cachedConfiguration.generateOutDates ||
                newDateBoundary.firstDayOfWeek      != _cachedConfiguration.firstDayOfWeek ||
                newDateBoundary.hasStrictBoundaries != _cachedConfiguration.hasStrictBoundaries ||
                // Other layout information were changed
                minimumInteritemSpacing  != calendarLayout.minimumInteritemSpacing ||
                minimumLineSpacing       != calendarLayout.minimumLineSpacing ||
                sectionInset             != calendarLayout.sectionInset ||
                lastMonthSize            != newLastMonth ||
                allowsDateCellStretching != calendarLayout.allowsDateCellStretching ||
                scrollDirection          != calendarLayout.scrollDirection ||
                calendarLayout.isDirty {
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
            let newPaths = pathsFromDates(selectedDates)
            
            // Get the new counter Paths
            var newCounterPaths: [IndexPath] = []
            for date in selectedDates {
                if let counterPath = indexPathOfdateCellCounterPath(date, dateOwner: .thisMonth) {
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
