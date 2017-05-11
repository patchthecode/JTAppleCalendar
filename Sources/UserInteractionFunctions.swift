//
//  UserInteractionFunctions.swift
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
    
    /// Returns the cellStatus of a date that is visible on the screen.
    /// If the row and column for the date cannot be found,
    /// then nil is returned
    /// - Paramater row: Int row of the date to find
    /// - Paramater column: Int column of the date to find
    /// - returns:
    ///     - CellState: The state of the found cell
    public func cellStatusForDate(at row: Int, column: Int) -> CellState? {
        guard let section = currentSection() else {
            return nil
        }
        let convertedRow = (row * maxNumberOfDaysInWeek) + column
        let indexPathToFind = IndexPath(item: convertedRow, section: section)
        if let date = dateOwnerInfoFromPath(indexPathToFind) {
            let stateOfCell = cellStateFromIndexPath(indexPathToFind, withDateInfo: date)
            return stateOfCell
        }
        return nil
    }
    
    /// Returns the cell status for a given date
    /// - Parameter: date Date of the cell you want to find
    /// - returns:
    ///     - CellState: The state of the found cell
    public func cellStatus(for date: Date) -> CellState? {
        // validate the path
        let paths = pathsFromDates([date])
        // Jt101 change this function to also return
        // information like the dateInfoFromPath function
        if paths.isEmpty { return nil }
        let cell = cellForItem(at: paths[0]) as? JTAppleCell
        let stateOfCell = cellStateFromIndexPath(paths[0], cell: cell)
        return stateOfCell
    }
    
    /// Returns the cell status for a given point
    /// - Parameter: point of the cell you want to find
    /// - returns:
    ///     - CellState: The state of the found cell
    public func cellStatus(at point: CGPoint) -> CellState? {
        if let indexPath = indexPathForItem(at: point) {
            let cell = cellForItem(at: indexPath) as? JTAppleCell
            return cellStateFromIndexPath(indexPath, cell: cell)
        }
        return nil
    }
    
    /// Deselect all selected dates
    /// - Parameter: this funciton triggers a delegate call by default. Set this to false if you do not want this
    public func deselectAllDates(triggerSelectionDelegate: Bool = true) {
        deselect(dates: selectedDates, triggerSelectionDelegate: triggerSelectionDelegate)
    }
    
    func deselect(dates: [Date], triggerSelectionDelegate: Bool = true) {
        if allowsMultipleSelection {
            selectDates(dates, triggerSelectionDelegate: triggerSelectionDelegate)
        } else {
            guard let path = pathsFromDates(dates).first else { return }
            collectionView(self, didDeselectItemAt: path)
        }
    }
    
    /// Generates a range of dates from from a startDate to an
    /// endDate you provide
    /// Parameter startDate: Start date to generate dates from
    /// Parameter endDate: End date to generate dates to
    /// returns:
    ///     - An array of the successfully generated dates
    public func generateDateRange(from startDate: Date, to endDate: Date) -> [Date] {
        if startDate > endDate {
            return []
        }
        var returnDates: [Date] = []
        var currentDate = startDate
        repeat {
            returnDates.append(currentDate)
            currentDate = calendar.startOfDay(for: calendar.date(
                byAdding: .day, value: 1, to: currentDate)!)
        } while currentDate <= endDate
        return returnDates
    }
    
    /// Registers a class for use in creating supplementary views for the collection view.
    /// For now, the calendar only supports: 'UICollectionElementKindSectionHeader' for the forSupplementaryViewOfKind(parameter)
    open override func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String) {
        super.register(viewClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    /// Registers a class for use in creating supplementary views for the collection view.
    /// For now, the calendar only supports: 'UICollectionElementKindSectionHeader' for the forSupplementaryViewOfKind(parameter)
    open override func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
        super.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    /// Dequeues re-usable calendar cells
    public func dequeueReusableJTAppleSupplementaryView(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> JTAppleCollectionReusableView {
        guard let headerView = dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                withReuseIdentifier: identifier,
                                                                for: indexPath) as? JTAppleCollectionReusableView else {
                                                                    developerError(string: "Error initializing Header View with identifier: '\(identifier)'")
                                                                    return JTAppleCollectionReusableView()
        }
        return headerView
    }
    
    /// Registers a nib for use in creating Decoration views for the collection view.
    public func registerDecorationView(nib: UINib?) {
        calendarViewLayout.register(nib, forDecorationViewOfKind: decorationViewID)
    }
    /// Registers a class for use in creating Decoration views for the collection view.
    public func register(viewClass className: AnyClass?, forDecorationViewOfKind kind: String) {
        calendarViewLayout.register(className, forDecorationViewOfKind: decorationViewID)
    }
    /// Dequeues a reuable calendar cell
    public func dequeueReusableJTAppleCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> JTAppleCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? JTAppleCell else {
            developerError(string: "Error initializing Cell View with identifier: '\(identifier)'")
            return JTAppleCell()
        }
        return cell
    }
    
    /// Reloads the data on the calendar view. Scroll delegates are not
    //  triggered with this function.
    /// - Parameter date: An anchordate that the calendar will
    ///                   scroll to after reload completes
    /// - Parameter animation: Scroll is animated if this is set to true
    /// - Parameter completionHandler: This closure will run after
    ///                                the reload is complete
    public func reloadData(completionHandler: (() -> Void)? = nil) {
        if isScrollInProgress || isReloadDataInProgress {
            delayedExecutionClosure.append {[unowned self] in
                self.reloadData(completionHandler: completionHandler)
            }
            return
        }
        
        isReloadDataInProgress = true
        
        let selectedDates = self.selectedDates
        let layoutNeedsUpdating = reloadDelegateDataSource()
        if layoutNeedsUpdating {
            calendarViewLayout.invalidateLayout()
            setupMonthInfoAndMap()
            
            self.theSelectedIndexPaths = []
            self.theSelectedDates = []
        }
        
        // Restore the selected index paths
        let restoreAfterReload = {
            if !selectedDates.isEmpty { // If layoutNeedsUpdating was false, layoutData would remain and re-selection wouldnt be needed
                self.selectDates(selectedDates, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            }
        }
        
        if !selectedDates.isEmpty { delayedExecutionClosure.append(restoreAfterReload) }
        if let validCompletionHandler = completionHandler  {
            delayedExecutionClosure.append(validCompletionHandler)
        }
        
        if !layoutNeedsUpdating { calendarViewLayout.shouldClearCacheOnInvalidate = false }
        super.reloadData()
        isReloadDataInProgress = false
        
        if !isCalendarLayoutLoaded { return } // Return if the reload is not yet complete and cells have not yet been re-generated
        if !delayedExecutionClosure.isEmpty { executeDelayedTasks() }
    }
    
    /// Reload the date of specified date-cells on the calendar-view
    /// - Parameter dates: Date-cells with these specified
    ///                    dates will be reloaded
    public func reloadDates(_ dates: [Date]) {
        var paths = [IndexPath]()
        for date in dates {
            let aPath = pathsFromDates([date])
            if !aPath.isEmpty && !paths.contains(aPath[0]) {
                paths.append(aPath[0])
                let cellState = cellStateFromIndexPath(aPath[0])
                if let validCounterPartCell = indexPathOfdateCellCounterPath(date,dateOwner: cellState.dateBelongsTo) {
                    paths.append(validCounterPartCell)
                }
            }
        }
        
        // Before reloading, set the proposal path,
        // so that in the event targetContentOffset gets called. We know the path
        calendarViewLayout.setMinVisibleDate()
        batchReloadIndexPaths(paths)
    }
    
    /// Select a date-cell range
    /// - Parameter startDate: Date to start the selection from
    /// - Parameter endDate: Date to end the selection from
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate
    ///   function only if the value is set to true.
    /// Sometimes it is necessary to setup some dates without triggereing
    /// the delegate e.g. For instance, when youre initally setting up data
    /// in your viewDidLoad
    /// - Parameter keepSelectionIfMultiSelectionAllowed: This is only
    ///   applicable in allowedMultiSelection = true.
    /// This overrides the default toggle behavior of selection.
    /// If true, selected cells will remain selected.
    public func selectDates(from startDate: Date, to endDate: Date, triggerSelectionDelegate: Bool = true, keepSelectionIfMultiSelectionAllowed: Bool = false) {
        selectDates(generateDateRange(from: startDate, to: endDate),
                    triggerSelectionDelegate: triggerSelectionDelegate,
                    keepSelectionIfMultiSelectionAllowed: keepSelectionIfMultiSelectionAllowed)
    }
    
    /// Deselect all selected dates within a range
    public func deselectDates(from start: Date, to end: Date? = nil, triggerSelectionDelegate: Bool = true) {
        if selectedDates.isEmpty { return }
        let end = end ?? selectedDates.last!
        let dates = selectedDates.filter { $0 >= start && $0 <= end }
        deselect(dates: dates, triggerSelectionDelegate: triggerSelectionDelegate)
        
    }
    
    /// Select a date-cells
    /// - Parameter date: The date-cell with this date will be selected
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function
    ///    only if the value is set to true.
    /// Sometimes it is necessary to setup some dates without triggereing
    /// the delegate e.g. For instance, when youre initally setting up data
    /// in your viewDidLoad
    public func selectDates(_ dates: [Date], triggerSelectionDelegate: Bool = true, keepSelectionIfMultiSelectionAllowed: Bool = false) {
        if dates.isEmpty { return }
        if (!isCalendarLayoutLoaded || isReloadDataInProgress) {
            // If the calendar is not yet fully loaded.
            // Add the task to the delayed queue
            delayedExecutionClosure.append {[unowned self] in
                self.selectDates(dates,
                                 triggerSelectionDelegate: triggerSelectionDelegate,
                                 keepSelectionIfMultiSelectionAllowed: keepSelectionIfMultiSelectionAllowed)
            }
            return
        }
        var allIndexPathsToReload: Set<IndexPath> = []
        var validDatesToSelect = dates
        // If user is trying to select multiple dates with
        // multiselection disabled, then only select the last object
        if !allowsMultipleSelection, let dateToSelect = dates.last {
            validDatesToSelect = [dateToSelect]
        }
        
        for date in validDatesToSelect {
            let date = calendar.startOfDay(for: date)
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let firstDayOfDate = calendar.date(from: components)!
            // If the date is not within valid boundaries, then exit
            if !(firstDayOfDate >= startOfMonthCache! && firstDayOfDate <= endOfMonthCache!) {
                continue
            }
            let pathFromDates = self.pathsFromDates([date])
            // If the date path youre searching for, doesnt exist, return
            if pathFromDates.isEmpty { continue }
            let sectionIndexPath = pathFromDates[0]
            // Remove old selections
            if self.allowsMultipleSelection == false {
                // If single selection is ON
                let selectedIndexPaths = self.theSelectedIndexPaths
                // made a copy because the array is about to be mutated
                for indexPath in selectedIndexPaths {
                    if indexPath != sectionIndexPath {
                        let pathsToReload = deselectDate(oldIndexPath: indexPath, shouldTriggerSelecteionDelegate: triggerSelectionDelegate)
                        allIndexPathsToReload.formUnion(pathsToReload)
                    }
                }
                // Add new selections Must be added here. If added in delegate didSelectItemAtIndexPath
                let pathsToReload = selectDate(indexPath: sectionIndexPath, date: date, shouldTriggerSelecteionDelegate: triggerSelectionDelegate)
                allIndexPathsToReload.formUnion(pathsToReload)
            } else {
                // If multiple selection is on. Multiple selection behaves differently to singleselection.
                // It behaves like a toggle. unless keepSelectionIfMultiSelectionAllowed is true.
                // If user wants to force selection if multiselection is enabled, then removed the selected dates from generated dates
                if keepSelectionIfMultiSelectionAllowed, selectedDates.contains(date) {
                    // Just add it to be reloaded
                    allIndexPathsToReload.insert(sectionIndexPath)
                } else {
                    if self.theSelectedIndexPaths.contains(sectionIndexPath) {
                        // If this cell is already selected, then deselect it
                        let pathsToReload = self.deselectDate(oldIndexPath: sectionIndexPath, shouldTriggerSelecteionDelegate: triggerSelectionDelegate)
                        allIndexPathsToReload.formUnion(pathsToReload)
                    } else {
                        // Add new selections
                        // Must be added here. If added in delegate didSelectItemAtIndexPath
                        let pathsToReload = self.selectDate(indexPath: sectionIndexPath, date: date, shouldTriggerSelecteionDelegate: triggerSelectionDelegate)
                        allIndexPathsToReload.formUnion(pathsToReload)
                    }
                }
            }
        }
        // If triggering was false, although the selectDelegates weren't
        // called, we do want the cell refreshed.
        // Reload to call itemAtIndexPath
        if !triggerSelectionDelegate && !allIndexPathsToReload.isEmpty {
            self.batchReloadIndexPaths(Array(allIndexPathsToReload))
        }
    }
    
    /// Scrolls the calendar view to the next section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Paramater direction: Indicates a direction to scroll
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter triggerScrollToDateDelegate: trigger delegate if set to true
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToSegment(_ destination: SegmentDestination,
                                triggerScrollToDateDelegate: Bool = true,
                                animateScroll: Bool = true,
                                extraAddedOffset: CGFloat = 0,
                                completionHandler: (() -> Void)? = nil) {
        if functionIsUnsafeSafeToRun {
            delayedExecutionClosure.append {[unowned self] in
                self.scrollToSegment(destination,
                                     triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                                     animateScroll: animateScroll,
                                     extraAddedOffset: extraAddedOffset,
                                     completionHandler: completionHandler)
            }
        }
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        let fixedScrollSize: CGFloat
        if scrollDirection == .horizontal {
            if calendarViewLayout.thereAreHeaders || cachedConfiguration.generateOutDates == .tillEndOfGrid {
                fixedScrollSize = calendarViewLayout.sizeOfContentForSection(0)
            } else {
                fixedScrollSize = frame.width
            }
            let section = CGFloat(Int(contentOffset.x / fixedScrollSize))
            xOffset = (fixedScrollSize * section)
            switch destination {
            case .next:
                xOffset += fixedScrollSize
            case .previous:
                xOffset -= fixedScrollSize
            case .end:
                xOffset = contentSize.width - frame.width
            case .start:
                xOffset = 0
            }
            
            if xOffset <= 0 {
                xOffset = 0
            } else if xOffset >= contentSize.width - frame.width {
                xOffset = contentSize.width - frame.width
            }
        } else {
            if calendarViewLayout.thereAreHeaders {
                guard let section = currentSection() else {
                    return
                }
                if (destination == .next && section + 1 >= numberOfSections(in: self)) ||
                    destination == .previous && section - 1 < 0 ||
                    numberOfSections(in: self) < 0 {
                    return
                }
                
                switch destination {
                case .next:
                    scrollToHeaderInSection(section + 1, extraAddedOffset: extraAddedOffset)
                case .previous:
                    scrollToHeaderInSection(section - 1, extraAddedOffset: extraAddedOffset)
                case .start:
                    scrollToHeaderInSection(0, extraAddedOffset: extraAddedOffset)
                case .end:
                    scrollToHeaderInSection(numberOfSections(in: self) - 1, extraAddedOffset: extraAddedOffset)
                }
                return
            } else {
                fixedScrollSize = frame.height
                let section = CGFloat(Int(contentOffset.y / fixedScrollSize))
                yOffset = (fixedScrollSize * section) + fixedScrollSize
            }
            
            if yOffset <= 0 {
                yOffset = 0
            } else if yOffset >= contentSize.height - frame.height {
                yOffset = contentSize.height - frame.height
            }
        }
        
        scrollTo(point: CGPoint(x: xOffset, y: yOffset),
                 triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                 isAnimationEnabled: animateScroll,
                 extraAddedOffset: extraAddedOffset,
                 completionHandler: completionHandler)
    }
    
    /// Scrolls the calendar view to the start of a section view containing a specified date.
    /// - Paramater date: The calendar view will scroll to a date-cell containing this date if it exists
    /// - Parameter triggerScrollToDateDelegate: Trigger delegate if set to true
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Paramater preferredScrollPositionIndex: Integer indicating the end scroll position on the screen.
    /// This value indicates column number for Horizontal scrolling and row number for a vertical scrolling calendar
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToDate(_ date: Date,
                             triggerScrollToDateDelegate: Bool = true,
                             animateScroll: Bool = true,
                             preferredScrollPosition: UICollectionViewScrollPosition? = nil,
                             extraAddedOffset: CGFloat = 0,
                             completionHandler: (() -> Void)? = nil) {
        
        // Ensure scrolling to date is safe to run
        if functionIsUnsafeSafeToRun {
            if !animateScroll  { initialScrollDate = date}
            delayedExecutionClosure.append {[unowned self] in
                self.scrollToDate(date,
                                  triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                                  animateScroll: animateScroll,
                                  preferredScrollPosition: preferredScrollPosition,
                                  extraAddedOffset: extraAddedOffset,
                                  completionHandler: completionHandler)
            }
            return
        }
        // Set triggereing of delegate on scroll
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        
        // Ensure date is within valid boundary
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let firstDayOfDate = calendar.date(from: components)!
        if !((firstDayOfDate >= self.startOfMonthCache!) && (firstDayOfDate <= self.endOfMonthCache!)) { return }
        
        // Get valid indexPath of date to scroll to
        let retrievedPathsFromDates = self.pathsFromDates([date])
        if retrievedPathsFromDates.isEmpty { return }
        let sectionIndexPath =  self.pathsFromDates([date])[0]
        
        // Ensure valid scroll position is set
        var position: UICollectionViewScrollPosition = self.scrollDirection == .horizontal ? .left : .top
        if !self.scrollingMode.pagingIsEnabled(),
            let validPosition = preferredScrollPosition {
            if self.scrollDirection == .horizontal {
                if validPosition == .left || validPosition == .right || validPosition == .centeredHorizontally {
                    position = validPosition
                }
            } else {
                if validPosition == .top || validPosition == .bottom || validPosition == .centeredVertically {
                    position = validPosition
                }
            }
        }
        
        var point: CGPoint?
        switch self.scrollingMode {
        case .stopAtEach, .stopAtEachSection, .stopAtEachCalendarFrameWidth:
            if self.scrollDirection == .horizontal || (scrollDirection == .vertical && !calendarViewLayout.thereAreHeaders) {
                point = self.targetPointForItemAt(indexPath: sectionIndexPath)
            }
        default:
            break
        }
        
        handleScroll(point: point,
                     indexPath: sectionIndexPath,
                     triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                     isAnimationEnabled: animateScroll,
                     position: position,
                     extraAddedOffset: extraAddedOffset,
                     completionHandler: completionHandler)
    }
    
    /// Scrolls the calendar view to the start of a section view header.
    /// If the calendar has no headers registered, then this function does nothing
    /// - Paramater date: The calendar view will scroll to the header of
    /// a this provided date
    public func scrollToHeaderForDate(_ date: Date,
                                      triggerScrollToDateDelegate: Bool = false,
                                      withAnimation animation: Bool = false,
                                      extraAddedOffset: CGFloat = 0,
                                      completionHandler: (() -> Void)? = nil) {
        if functionIsUnsafeSafeToRun {
            if !animation  { initialScrollDate = date}
            delayedExecutionClosure.append {[unowned self] in
                self.scrollToHeaderForDate(date,
                                           triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                                           withAnimation: animation,
                                           extraAddedOffset: extraAddedOffset,
                                           completionHandler: completionHandler)
            }
            return
        }
        let path = pathsFromDates([date])
        // Return if date was incalid and no path was returned
        if path.isEmpty { return }
        scrollToHeaderInSection(
            path[0].section,
            triggerScrollToDateDelegate: triggerScrollToDateDelegate,
            withAnimation: animation,
            extraAddedOffset: extraAddedOffset,
            completionHandler: completionHandler
        )
    }
    
    /// Returns the visible dates of the calendar.
    /// - returns:
    ///     - DateSegmentInfo
    public func visibleDates()-> DateSegmentInfo {
        let emptySegment = DateSegmentInfo(indates: [], monthDates: [], outdates: [])
        
        if !isCalendarLayoutLoaded {
            return emptySegment
        }
        
        let cellAttributes = calendarViewLayout.visibleElements(excludeHeaders: true)
        let indexPaths: [IndexPath] = cellAttributes.map { $0.indexPath }.sorted()
        return dateSegmentInfoFrom(visible: indexPaths)
    }
    /// Returns the visible dates of the calendar.
    /// - returns:
    ///     - DateSegmentInfo
    public func visibleDates(_ completionHandler: @escaping (_ dateSegmentInfo: DateSegmentInfo) ->()) {
        if functionIsUnsafeSafeToRun {
            delayedExecutionClosure.append {[unowned self] in
                self.visibleDates(completionHandler)
            }
            return
        }
        let retval = visibleDates()
        completionHandler(retval)
    }
}
