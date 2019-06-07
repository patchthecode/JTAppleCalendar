//
//  JTACInteractionMonthFunctions.swift
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


extension JTACMonthView {
    
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
        if !calendarLayoutIsLoaded || isReloadDataInProgress { return nil }
        // validate the path
        let paths = pathsFromDates([date])
        // Jt101 change this function to also return
        // information like the dateInfoFromPath function
        if paths.isEmpty { return nil }
        let cell = cellForItem(at: paths[0]) as? JTACDayCell
        let stateOfCell = cellStateFromIndexPath(paths[0], cell: cell)
        return stateOfCell
    }
    
    /// Returns the cell status for a given date
    /// - Parameter: date Date of the cell you want to find
    /// - returns:
    ///     - CellState: The state of the found cell
    public func cellStatus(for date: Date, completionHandler: @escaping (_ cellStatus: CellState?) ->()) {
        if !calendarLayoutIsLoaded || isReloadDataInProgress {
            addToDelayedHandlers {[unowned self] in
                self.cellStatus(for: date, completionHandler: completionHandler)
            }
            return
        }
        let retval = cellStatus(for: date)
        completionHandler(retval)
    }
    
    func addToDelayedHandlers(function: @escaping ()->()) {
        if isScrollInProgress {
            scrollDelayedExecutionClosure.append { function() }
        } else {
            generalDelayedExecutionClosure.append { function() }
        }
    }
    
    /// Returns the month status for a given date
    /// - Parameter: date Date of the cell you want to find
    /// - returns:
    ///     - Month: The state of the found month
    public func monthStatus(for date: Date) -> Month? {
        guard
            let calendar = _cachedConfiguration?.calendar,
            let startMonth = startOfMonthCache,
            let monthIndex = calendar.dateComponents([.month], from: startMonth, to: date).month else {
                return nil
        }
        return monthInfo[monthIndex]
    }
    
    /// Returns the cell status for a given point
    /// - Parameter: point of the cell you want to find
    /// - returns:
    ///     - CellState: The state of the found cell
    public func cellStatus(at point: CGPoint) -> CellState? {
        if let indexPath = indexPathForItem(at: point) {
            let cell = cellForItem(at: indexPath) as? JTACDayCell
            return cellStateFromIndexPath(indexPath, cell: cell)
        }
        return nil
    }
    
    /// Deselect all selected dates
    /// - Parameter: this funciton triggers a delegate call by default. Set this to false if you do not want this
    /// - Parameter keepDeselectionIfMultiSelectionAllowed:
    ///    if (in range selection) there are 4 dates. -> selected, unselected, selected, selected. (S | U | S | S)
    ///    Deselecting those 4 dates again would give U | S | U | U. With KeepDeselection, this becomes U | U | U | U
    public func deselectAllDates(triggerSelectionDelegate: Bool = true) {
        deselect(dates: selectedDates, triggerSelectionDelegate: triggerSelectionDelegate)
    }
    
    /// Deselect dates
    /// - Parameter: Dates - The dates to deselect
    /// - Parameter: triggerSelectionDelegate - this funciton triggers a delegate call by default. Set this to false if you do not want this
    /// - Parameter keepDeselectionIfMultiSelectionAllowed:
    ///    if (in range selection) there are 4 dates. -> selected, unselected, selected, selected. (S | U | S | S)
    ///    Deselecting those 4 dates again would give U | S | U | U. With KeepDeselection, this becomes U | U | U | U
    public func deselect(dates: [Date], triggerSelectionDelegate: Bool = true, keepDeselectionIfMultiSelectionAllowed: Bool = false) {
        if allowsMultipleSelection {
            var filteredDates: [Date] = dates
            if keepDeselectionIfMultiSelectionAllowed {
                filteredDates = dates.filter { self.selectedDatesSet.contains(calendar.startOfDay(for: $0)) }
            }
            selectDates(filteredDates, triggerSelectionDelegate: triggerSelectionDelegate, keepSelectionIfMultiSelectionAllowed: false)
        } else {
            let paths = pathsFromDates(dates)
            guard !paths.isEmpty else { return }
            assert(paths.count < 2, "WARNING: you are trying to deselect multiple dates with allowsMultipleSelection == false. Only the first date will be deselected.")
            collectionView(self, didDeselectItemAt: paths[0])
        }
    }
    
    /// Notifies the container that the size of its view is about to change.
    public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator, anchorDate: Date?) {
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else { return }
            _self.reloadData(withAnchor: anchorDate)
        }
    }
    
    /// Generates a range of dates from from a startDate to an
    /// endDate you provide
    /// Parameter startDate: Start date to generate dates from
    /// Parameter endDate: End date to generate dates to
    /// returns:
    ///     - An array of the successfully generated dates
    public func generateDateRange(from startDate: Date, to endDate: Date) -> [Date] {
        if startDate > endDate { return [] }
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
        super.register(viewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    /// Registers a class for use in creating supplementary views for the collection view.
    /// For now, the calendar only supports: 'UICollectionElementKindSectionHeader' for the forSupplementaryViewOfKind(parameter)
    open override func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
        super.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    /// Dequeues re-usable calendar cells
    public func dequeueReusableJTAppleSupplementaryView(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> JTACMonthReusableView {
        guard let headerView = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                withReuseIdentifier: identifier,
                                                                for: indexPath) as? JTACMonthReusableView else {
                                                                    developerError(string: "Error initializing Header View with identifier: '\(identifier)'")
                                                                    return JTACMonthReusableView()
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
    public func dequeueReusableJTAppleCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> JTACDayCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? JTACDayCell else {
            developerError(string: "Error initializing Cell View with identifier: '\(identifier)'")
            return JTACDayCell()
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
    public func reloadData(withAnchor date: Date? = nil, completionHandler: (() -> Void)? = nil) {
        if isReloadDataInProgress { return }
        if isScrollInProgress {
            scrollDelayedExecutionClosure.append {[unowned self] in
                self.reloadData(completionHandler: completionHandler)
            }
            return
        }
        
        isReloadDataInProgress = true
        anchorDate = date
        
        let selectedDates = self.selectedDates
        let data = reloadDelegateDataSource()
        if data.shouldReload {
            calendarViewLayout.clearCache()
            setupMonthInfoAndMap(with: data.configParameters)
            selectedCellData = [:]
        }

        // Restore the selected index paths if dates were already selected.
        if !selectedDates.isEmpty {
            calendarViewLayout.delayedExecutionClosure.append {[weak self] in
                guard let _self = self else { return}
                _self.isReloadDataInProgress = false
                _self.selectDates(selectedDates, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            }
        }

        // Add calendar reload completion 
        calendarViewLayout.delayedExecutionClosure.append {[weak self] in
            guard let _self = self else { return }
            _self.isReloadDataInProgress = false
            completionHandler?()
            if !_self.generalDelayedExecutionClosure.isEmpty { _self.executeDelayedTasks(.general) }
        }
        calendarViewLayout.reloadWasTriggered = true
        DispatchQueue.main.async {
            super.reloadData()
        }
    }
    
    /// Reload the date of specified date-cells on the calendar-view
    /// - Parameter dates: Date-cells with these specified
    ///                    dates will be reloaded
    public func reloadDates(_ dates: [Date]) {
        var paths: Set<IndexPath> = []
        for date in dates {
            let aPath = pathsFromDates([date])
            if let validPath = aPath.first {
                paths.insert(validPath)
                let cellState = cellStateFromIndexPath(validPath)
                if let validCounterPartCellPath = indexPathOfdateCellCounterPath(date,dateOwner: cellState.dateBelongsTo) {
                    paths.insert(validCounterPartCellPath)
                }
            }
        }
        batchReloadIndexPaths(Array(paths))
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
    /// - Parameter: start - Start of date range to deselect
    /// - Parameter: end of date range to deselect
    /// - Parameter keepDeselectionIfMultiSelectionAllowed:
    ///    if (in range selection) there are 4 dates. -> selected, unselected, selected, selected. (S | U | S | S)
    ///    Deselecting those 4 dates again would give U | S | U | U. With KeepDeselection, this becomes U | U | U | U
    public func deselectDates(from start: Date, to end: Date? = nil, triggerSelectionDelegate: Bool = true, keepDeselectionIfMultiSelectionAllowed: Bool = false) {
        if selectedDates.isEmpty { return }
        let end = end ?? selectedDates.last!
        let dates = selectedDates.filter { $0 >= start && $0 <= end }
        deselect(dates: dates, triggerSelectionDelegate: triggerSelectionDelegate, keepDeselectionIfMultiSelectionAllowed: keepDeselectionIfMultiSelectionAllowed)
        
    }
    
    /// Select a date-cells
    /// - Parameter date: The date-cell with this date will be selected
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function
    ///    only if the value is set to true.
    /// Sometimes it is necessary to setup some dates without triggereing
    /// the delegate e.g. For instance, when youre initally setting up data
    /// in your viewDidLoad
    /// - Parameter keepSelectionIfMultiSelectionAllowed:
    ///    if (in range selection) there are 4 dates. -> selected, unselected, selected, selected. (S | U | S | S)
    ///    Selecting those 4 dates again would give U | S | U | U. With KeepSelection, this becomes S | S | S | S
    public func selectDates(_ dates: [Date], triggerSelectionDelegate: Bool = true, keepSelectionIfMultiSelectionAllowed: Bool = false) {
        if dates.isEmpty { return }
        if (!calendarLayoutIsLoaded || isReloadDataInProgress) {
            // If the calendar is not yet fully loaded.
            // Add the task to the delayed queue
            generalDelayedExecutionClosure.append {[unowned self] in
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
            if !(firstDayOfDate >= startOfMonthCache! && firstDayOfDate <= endOfMonthCache!) { continue }
            
            let pathFromDates = pathsFromDates([date])
            // If the date path youre searching for, doesnt exist, return
            if pathFromDates.isEmpty { continue }
            let sectionIndexPath = pathFromDates[0]
            
            // Remove old selections
            if allowsMultipleSelection {
                // If multiple selection is on. Multiple selection behaves differently to singleselection.
                // It behaves like a toggle. unless keepSelectionIfMultiSelectionAllowed is true.
                // If user wants to force selection if multiselection is enabled, then removed the selected dates from generated dates
                if keepSelectionIfMultiSelectionAllowed, selectedDates.contains(date) {
                    guard
                        let selectedIndexPaths = indexPathsForSelectedItems,
                        selectedIndexPaths.contains(sectionIndexPath) else {
                            // Select the item if it is not selected (not included in indexPathsForSelectedItems).
                            // This makes the cell to be in selected state thus, if selected physically, will call the didDeselect function
                            programaticallySelectItem(at: sectionIndexPath, shouldTriggerSelectionDelegate: triggerSelectionDelegate)
                            continue
                    }
                    // Just add it to be reloaded, if it is already selected
                    allIndexPathsToReload.insert(sectionIndexPath)
                } else {
                    if selectedCellData[sectionIndexPath] != nil { // If this cell is already selected, then deselect it
                        programaticallyDeselectItem(at: sectionIndexPath, shouldTriggerSelectionDelegate: triggerSelectionDelegate)
                    } else { // If this cell is unselected, then select it
                        programaticallySelectItem(at: sectionIndexPath, shouldTriggerSelectionDelegate: triggerSelectionDelegate)
                    }
                }
            } else {
                // If single selection is ON
                let selectedIndexPaths = selectedCellData
                
                if let cellData = (selectedIndexPaths.filter { $0.key != sectionIndexPath  }.first) {
                    programaticallyDeselectItem(at: cellData.value.indexPath, shouldTriggerSelectionDelegate: triggerSelectionDelegate)
                }
                // Add new selections Must be added here. If added in delegate didSelectItemAtIndexPath
                programaticallySelectItem(at: sectionIndexPath, shouldTriggerSelectionDelegate: triggerSelectionDelegate)
            }
        }
        // If triggering was false, although the selectDelegates weren't
        // called, we do want the cell refreshed. Reload to call itemAtIndexPath
        if !triggerSelectionDelegate && !allIndexPathsToReload.isEmpty {
            // Because sometimes if not on main thread, it will not get the
            // visible cells in the following function
            DispatchQueue.main.async {
                self.batchReloadIndexPaths(Array(allIndexPathsToReload))
            }
        }
    }

    func programaticallyDeselectItem(at indexPath: IndexPath, shouldTriggerSelectionDelegate: Bool) {
        if !handleShouldSelectionValueChange(self, action: .shouldDeselect, indexPath: indexPath, selectionType: .programatic) { return }
        deselectItem(at: indexPath, animated: false)
        handleSelectionValueChanged(self, action: .didDeselect, indexPath: indexPath, selectionType: .programatic, shouldTriggerSelectionDelegate: shouldTriggerSelectionDelegate)
    }

    func programaticallySelectItem(at indexPath: IndexPath, shouldTriggerSelectionDelegate: Bool) {
        if !handleShouldSelectionValueChange(self, action: .shouldSelect, indexPath: indexPath, selectionType: .programatic) { return }
        selectItem(at: indexPath, animated: false, scrollPosition: [])
        handleSelectionValueChanged(self, action: .didSelect, indexPath: indexPath, selectionType: .programatic, shouldTriggerSelectionDelegate: shouldTriggerSelectionDelegate)
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
            addToDelayedHandlers {[unowned self] in
                self.scrollToSegment(destination,
                                     triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                                     animateScroll: animateScroll,
                                     extraAddedOffset: extraAddedOffset,
                                     completionHandler: completionHandler)
            }
            return
        }

        let fixedScrollSize: CGFloat
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        switch scrollDirection {
        case .horizontal:
            if calendarViewLayout.thereAreHeaders || _cachedConfiguration.generateOutDates == .tillEndOfGrid {
                fixedScrollSize = calendarViewLayout.sizeOfContentForSection(0)
            } else {
                fixedScrollSize = frame.width
            }
            
            var section = contentOffset.x / fixedScrollSize
            let roundedSection = round(section)
            if abs(roundedSection - section) < errorDelta { section = roundedSection }
            section = CGFloat(Int(section))
            
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
        case .vertical:
            fallthrough
        default:
            guard let currentSection = currentSection() else { return }
            if (destination == .next && currentSection + 1 >= numberOfSections(in: self)) ||
                destination == .previous && currentSection - 1 < 0 ||
                numberOfSections(in: self) < 0 {
                return
            }
            
            if calendarViewLayout.thereAreHeaders {
                
                switch destination {
                case .next:
                    scrollToHeaderInSection(currentSection + 1, extraAddedOffset: extraAddedOffset, completionHandler: completionHandler)
                case .previous:
                    scrollToHeaderInSection(currentSection - 1, extraAddedOffset: extraAddedOffset, completionHandler: completionHandler)
                case .start:
                    scrollToHeaderInSection(0, extraAddedOffset: extraAddedOffset, completionHandler: completionHandler)
                case .end:
                    scrollToHeaderInSection(numberOfSections(in: self) - 1, extraAddedOffset: extraAddedOffset, completionHandler: completionHandler)
                }
                return
            } else {
                switch destination {
                case .next: yOffset = calendarViewLayout.cachedValue(for: 0, section: currentSection + 1)?.3 ?? contentSize.height // Set to max on nil
                case .end: yOffset = contentSize.height // Set to max
                case .previous: yOffset = calendarViewLayout.cachedValue(for: 0, section: currentSection - 1)?.3 ?? 0 // Set min on nil
                case .start: yOffset = 0 // Set to min
                }
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
                             preferredScrollPosition: UICollectionView.ScrollPosition? = nil,
                             extraAddedOffset: CGFloat = 0,
                             completionHandler: (() -> Void)? = nil) {
        
        // Ensure scrolling to date is safe to run
        if functionIsUnsafeSafeToRun {
            if !animateScroll  { anchorDate = date} // Gets rid of visible scrolling when calendar starts
            addToDelayedHandlers {[unowned self] in
                self.scrollToDate(date,
                                  triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                                  animateScroll: animateScroll,
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
        if !((firstDayOfDate >= startOfMonthCache!) && (firstDayOfDate <= endOfMonthCache!)) { return }
        
        // Get valid indexPath of date to scroll to
        let retrievedPathsFromDates = pathsFromDates([date])
        if retrievedPathsFromDates.isEmpty { return }
        let sectionIndexPath = pathsFromDates([date])[0]
        
        guard let point = targetPointForItemAt(indexPath: sectionIndexPath) else {
            assert(false, "Could not determine CGPoint. This is an error. contact developer on github. In production, there will not be a crash, but scrolling will not occur")
            return
        }

        scrollTo(point: point,
                 triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                 isAnimationEnabled: animateScroll,
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
            if !animation  { anchorDate = date}
            addToDelayedHandlers { [unowned self] in
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
        return datesAtCurrentOffset()
    }
    
    /// Returns the visible dates of the calendar.
    /// - returns:
    ///     - DateSegmentInfo
    public func visibleDates(_ completionHandler: @escaping (_ dateSegmentInfo: DateSegmentInfo) ->()) {
        if functionIsUnsafeSafeToRun {
            addToDelayedHandlers { [unowned self] in self.visibleDates(completionHandler) }
            return
        }
        let retval = visibleDates()
        completionHandler(retval)
    }
    
    /// Retrieves the current section
    public func currentSection() -> Int? {
        let minVisiblePaths = calendarViewLayout.minimumVisibleIndexPaths()
        return minVisiblePaths.cellIndex?.section
    }
}
