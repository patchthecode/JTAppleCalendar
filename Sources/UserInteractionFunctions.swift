//
//  UserInteractionFunctions.swift
//  Pods
//
//  Created by JayT on 2016-05-12.
//
//


extension JTAppleCalendarView {
    /// Returns the cellStatus of a date that is visible on the screen. If the row and column for the date cannot be found, then nil is returned
    /// - Paramater row: Int row of the date to find
    /// - Paramater column: Int column of the date to find
    /// - returns:
    ///     - CellState: The state of the found cell
    public func cellStatusForDateAtRow(row: Int, column: Int) -> CellState? {
        let convertedRow = (row * MAX_NUMBER_OF_DAYS_IN_WEEK) + column  
        let indexPathToFind = NSIndexPath(forItem: convertedRow, inSection: currentSectionPage)
        if let  date = dateFromPath(indexPathToFind) {
            let stateOfCell = cellStateFromIndexPath(indexPathToFind, withDate: date)
            return stateOfCell
        }
        return nil
    }
    /// Returns the cell status for a given date
    /// - Parameter: date Date of the cell you which to find
    /// - returns:
    ///     - CellState: The state of the found cell
    public func cellStatusForDate(date: NSDate)-> CellState? {
        // validate the path
        let paths = pathsFromDates([date])
        if paths.count < 1 { return nil }
        let cell = calendarView.cellForItemAtIndexPath(paths[0]) as? JTAppleDayCell
        let stateOfCell = cellStateFromIndexPath(paths[0], withDate: date, cell: cell)
        return stateOfCell
    }
    
    /// Returns the calendar view's current section boundary dates.
    /// - returns:
    ///     - startDate: The start date of the current section
    ///     - endDate: The end date of the current section
    public func currentCalendarDateSegment() -> (dateRange:(start: NSDate, end: NSDate), month: Int) {
        guard let dateSegment = dateFromSection(currentSectionPage) else {
            assert(false, "Error in currentCalendarDateSegment method. Report this issue to Jay on github.")
            return ((NSDate(), NSDate()), 0)
        }
        return dateSegment
    }
    
    /// Let's the calendar know which cell xib to use for the displaying of it's date-cells.
    /// - Parameter name: The name of the xib of your cell design
    public func registerCellViewXib(fileName name: String) { cellViewSource = JTAppleCalendarViewSource.fromXib(name) }
    
    /// Let's the calendar know which cell class to use for the displaying of it's date-cells.
    /// - Parameter name: The class name of your cell design
    public func registerCellViewClass(fileName name: String) { cellViewSource = JTAppleCalendarViewSource.fromClassName(name) }
    
    /// Let's the calendar know which cell class to use for the displaying of it's date-cells.
    /// - Parameter name: The type of your cell design
    public func registerCellViewClass(cellClass cellClass: AnyClass) { cellViewSource = JTAppleCalendarViewSource.fromType(cellClass) }
    
    /// Register header views with the calender. This needs to be done before the view can be displayed
    /// - Parameter fileNames: A dictionary containing [headerViewNames:HeaderviewSizes]
    public func registerHeaderViewXibs(fileNames headerViewXibNames: [String]) {
        registeredHeaderViews.removeAll() // remove the already registered xib files if the user re-registers again.
        for headerViewXibName in headerViewXibNames {
            registeredHeaderViews.append(JTAppleCalendarViewSource.fromXib(headerViewXibName))
            self.calendarView.registerClass(JTAppleCollectionReusableView.self,
                                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                            withReuseIdentifier: headerViewXibName)
        }
    }
    /// Register header views with the calender. This needs to be done before the view can be displayed
    /// - Parameter fileNames: A dictionary containing [headerViewNames:HeaderviewSizes]
    public func registerHeaderViewClass(fileNames headerViewClassNames: [String]) {
        registeredHeaderViews.removeAll() // remove the already registered xib files if the user re-registers again.
        for headerViewClassName in headerViewClassNames {
            registeredHeaderViews.append(JTAppleCalendarViewSource.fromClassName(headerViewClassName))
            self.calendarView.registerClass(JTAppleCollectionReusableView.self,
                                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                            withReuseIdentifier: headerViewClassName)
        }
    }
    /// Register header views with the calender. This needs to be done before the view can be displayed
    /// - Parameter fileNames: A dictionary containing [headerViewNames:HeaderviewSizes]
    public func registerHeaderViewClass(headerClass headerViewClasses: [AnyClass]) {
        registeredHeaderViews.removeAll() // remove the already registered xib files if the user re-registers again.
        for aClass in headerViewClasses {
            registeredHeaderViews.append(JTAppleCalendarViewSource.fromType(aClass))
            self.calendarView.registerClass(JTAppleCollectionReusableView.self,
                                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                            withReuseIdentifier: aClass.description())
        }
    }
    
    /// Reloads the data on the calendar view. Scroll delegates are not triggered with this function.
    public func reloadData(withAnchorDate date:NSDate? = nil, withAnimation animation: Bool = false, completionHandler: (()->Void)? = nil) {
        reloadData(checkDelegateDataSource: true, withAnchorDate: date, withAnimation: animation, completionHandler: completionHandler)
    }
    
    /// Reload the date of specified date-cells on the calendar-view
    /// - Parameter dates: Date-cells with these specified dates will be reloaded
    public func reloadDates(dates: [NSDate]) {
        var paths = [NSIndexPath]()
        for date in dates {
            var aPath = pathsFromDates([date])
            
            if aPath.count > 0 {
                let cellState = cellStateFromIndexPath(aPath[0], withDate: date)
                if let validCounterPartCell = indexPathOfdateCellCounterPart(date, indexPath: aPath[0], dateOwner: cellState.dateBelongsTo) {
                    aPath[0] = validCounterPartCell
                }
            }
            paths.appendContentsOf(aPath)
        }
        batchReloadIndexPaths(paths)    }
    
    /// Select a date-cell range
    /// - Parameter startDate: Date to start the selection from
    /// - Parameter endDate: Date to end the selection from
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function only if the value is set to true. Sometimes it is necessary to setup some dates without triggereing the delegate e.g. For instance, when youre initally setting up data in your viewDidLoad
    /// - Parameter keepSelectionIfMultiSelectionAllowed: This is only applicable in allowedMultiSelection = true. This overrides the default toggle behavior of selection. If true, selected cells will remain selected.
    public func selectDates(from startDate:NSDate, to endDate:NSDate, triggerSelectionDelegate: Bool = true, keepSelectionIfMultiSelectionAllowed: Bool = false) {
        selectDates(generateDateRange(from: startDate, to: endDate), triggerSelectionDelegate: triggerSelectionDelegate, keepSelectionIfMultiSelectionAllowed: keepSelectionIfMultiSelectionAllowed)
    }
    
    /// Select a date-cells
    /// - Parameter date: The date-cell with this date will be selected
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function only if the value is set to true. Sometimes it is necessary to setup some dates without triggereing the delegate e.g. For instance, when youre initally setting up data in your viewDidLoad
    public func selectDates(dates: [NSDate], triggerSelectionDelegate: Bool = true, keepSelectionIfMultiSelectionAllowed: Bool = false) {
        var allIndexPathsToReload: [NSIndexPath] = []
        var validDatesToSelect = dates
        // If user is trying to select multiple dates with multiselection disabled, then only select the last object
        if !calendarView.allowsMultipleSelection && dates.count > 0 { validDatesToSelect = [dates.last!] }
        
        let addToIndexSetToReload = {(indexPath: NSIndexPath)->Void in
            if !allIndexPathsToReload.contains(indexPath) { allIndexPathsToReload.append(indexPath) } // To avoid adding the  same indexPath twice.
        }
        
        let selectTheDate = {(indexPath: NSIndexPath, date: NSDate) -> Void in
            self.calendarView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            addToIndexSetToReload(indexPath)
            // If triggereing is enabled, then let their delegate handle the reloading of view, else we will reload the data
            if triggerSelectionDelegate {
                self.internalCollectionView(self.calendarView, didSelectItemAtIndexPath: indexPath)
            } else { // Although we do not want the delegate triggered, we still want counterpart cells to be selected
                
                // Because there is no triggering of the delegate, the cell will not be added to selection and it will not be reloaded. We need to do this here
                self.addCellToSelectedSetIfUnselected(indexPath, date: date)
                let cellState = self.cellStateFromIndexPath(indexPath, withDate: date)
                if let aSelectedCounterPartIndexPath = self.selectCounterPartCellIndexPathIfExists(indexPath, date: date, dateOwner: cellState.dateBelongsTo) {
                    // If there was a counterpart cell then it will also need to be reloaded
                    addToIndexSetToReload(aSelectedCounterPartIndexPath)
                }
            }
        }
        
        let deSelectTheDate = { (oldIndexPath: NSIndexPath) -> Void in
            addToIndexSetToReload(oldIndexPath)
            if let index = self.theSelectedIndexPaths.indexOf(oldIndexPath) {
                let oldDate = self.theSelectedDates[index]
                self.calendarView.deselectItemAtIndexPath(oldIndexPath, animated: false)
                self.theSelectedIndexPaths.removeAtIndex(index)
                self.theSelectedDates.removeAtIndex(index)
                
                // If delegate triggering is enabled, let the delegate function handle the cell
                if triggerSelectionDelegate {
                    self.internalCollectionView(self.calendarView, didDeselectItemAtIndexPath: oldIndexPath)
                } else { // Although we do not want the delegate triggered, we still want counterpart cells to be deselected
                    let cellState = self.cellStateFromIndexPath(oldIndexPath, withDate: oldDate)
                    if let anUnselectedCounterPartIndexPath = self.deselectCounterPartCellIndexPath(oldIndexPath, date: oldDate, dateOwner: cellState.dateBelongsTo) {
                        // If there was a counterpart cell then it will also need to be reloaded
                        addToIndexSetToReload(anUnselectedCounterPartIndexPath)
                    }
                }
            }
        }
        
        for date in validDatesToSelect {
            let components = self.calendar.components([.Year, .Month, .Day],  fromDate: date)
            let firstDayOfDate = self.calendar.dateFromComponents(components)!
            
            // If the date is not within valid boundaries, then exit
            if !(firstDayOfDate >= self.startOfMonthCache && firstDayOfDate <= self.endOfMonthCache) { continue }
            let pathFromDates = self.pathsFromDates([date])
            
            // If the date path youre searching for, doesnt exist, then return
            if pathFromDates.count < 0 { continue }
            let sectionIndexPath = pathFromDates[0]
            
            // Remove old selections
            if self.calendarView.allowsMultipleSelection == false { // If single selection is ON
                let selectedIndexPaths = self.theSelectedIndexPaths // made a copy because the array is about to be mutated
                for indexPath in selectedIndexPaths {
                    if indexPath != sectionIndexPath { deSelectTheDate(indexPath) }
                }
                
                // Add new selections
                // Must be added here. If added in delegate didSelectItemAtIndexPath
                selectTheDate(sectionIndexPath, date)
            } else { // If multiple selection is on. Multiple selection behaves differently to singleselection. It behaves like a toggle. unless keepSelectionIfMultiSelectionAllowed is true.
                // If user wants to force selection if multiselection is enabled, then removed the selected dates from generated dates
                if keepSelectionIfMultiSelectionAllowed {
                    if selectedDates.contains(calendar.startOfDayForDate(date)) {
                        addToIndexSetToReload(sectionIndexPath)
                        continue // Do not deselect or select the cell. Just add it to be reloaded
                    }
                }
                if self.theSelectedIndexPaths.contains(sectionIndexPath) { // If this cell is already selected, then deselect it
                    deSelectTheDate(sectionIndexPath)
                } else {
                    // Add new selections
                    // Must be added here. If added in delegate didSelectItemAtIndexPath
                    selectTheDate(sectionIndexPath, date)
                }
            }
        }
        
        
        // If triggering was false, although the selectDelegates weren't called, we do want the cell refreshed. Reload to call itemAtIndexPath
        if /*triggerSelectionDelegate == false &&*/ allIndexPathsToReload.count > 0 {
            delayRunOnMainThread(0.0) {
                self.batchReloadIndexPaths(allIndexPathsToReload)
            }
        }
    }
    
    /// Scrolls the calendar view to the next section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter triggerScrollToDateDelegate: Trigger delegate if set to true
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToNextSegment(triggerScrollToDateDelegate: Bool = false, animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        let page = currentSectionPage + 1
        if page < monthInfo.count {
            scrollToSection(page, triggerScrollToDateDelegate: triggerScrollToDateDelegate, animateScroll: animateScroll, completionHandler: completionHandler)
        }
    }
    /// Scrolls the calendar view to the previous section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Parameter triggerScrollToDateDelegate: Trigger delegate if set to true
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToPreviousSegment(triggerScrollToDateDelegate: Bool = false, animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        let page = currentSectionPage - 1
        if page > -1 {
            scrollToSection(page, triggerScrollToDateDelegate: triggerScrollToDateDelegate, animateScroll: animateScroll, completionHandler: completionHandler)
        }
    }

    /// Scrolls the calendar view to the start of a section view containing a specified date.
    /// - Paramater date: The calendar view will scroll to a date-cell containing this date if it exists
    /// - Parameter triggerScrollToDateDelegate: Trigger delegate if set to true
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Paramater preferredScrollPositionIndex: Integer indicating the end scroll position on the screen. This value indicates column number for Horizontal scrolling and row number for a vertical scrolling calendar
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToDate(date: NSDate, triggerScrollToDateDelegate: Bool = true, animateScroll: Bool = true, preferredScrollPosition: UICollectionViewScrollPosition? = nil, completionHandler:(()->Void)? = nil) {
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        
        let components = calendar.components([.Year, .Month, .Day],  fromDate: date)
        let firstDayOfDate = calendar.dateFromComponents(components)!
        
        scrollInProgress = true
        delayRunOnMainThread(0.0, closure: {
            // This part should be inside the mainRunLoop
            if !(firstDayOfDate >= self.startOfMonthCache && firstDayOfDate <= self.endOfMonthCache) {
                self.scrollInProgress = false
                return
            }
            let retrievedPathsFromDates = self.pathsFromDates([date])
            if retrievedPathsFromDates.count > 0 {
                let sectionIndexPath =  self.pathsFromDates([date])[0]
                var position: UICollectionViewScrollPosition = self.direction == .Horizontal ? .Left : .Top
                if !self.scrollingMode.pagingIsEnabled() {
                    if let validPosition:UICollectionViewScrollPosition = preferredScrollPosition {
                        if self.direction == .Horizontal {
                            if validPosition == .Left || validPosition == .Right || validPosition == .CenteredHorizontally {
                                position = validPosition
                            } else {
                                position = .Left
                            }
                        } else {
                            if validPosition == .Top || validPosition == .Bottom || validPosition == .CenteredVertically {
                                position = validPosition
                            } else {
                                position = .Top
                            }
                        }
                    }
                }
                
                let scrollToIndexPath = {(iPath: NSIndexPath, withAnimation: Bool)-> Void in
                    if let validCompletionHandler = completionHandler { self.delayedExecutionClosure.append(validCompletionHandler) }
                     
                    // regular movement
                    self.calendarView.scrollToItemAtIndexPath(iPath, atScrollPosition: position, animated: animateScroll)
                    
                    if animateScroll {
                        if let check = self.calendarOffsetIsAlreadyAtScrollPosition(forIndexPath: iPath) where check == true {
                                self.scrollViewDidEndScrollingAnimation(self.calendarView)
                                self.scrollInProgress = false
                                return
                        }
                    }
                }
                
                if self.scrollingMode.pagingIsEnabled() {
                    if self.registeredHeaderViews.count > 0 {
                        // If both paging and header is on, then scroll to the actual date
                        // If direction is vertical and user has a custom size that is at least the size of the collectionview. 
                        // If this check is not done, it will scroll to header, and have white space at bottom because view is smaller due to small custom user itemSize
                        if self.direction == .Vertical && (self.calendarView.collectionViewLayout as! JTAppleCalendarLayout).sizeOfSection(sectionIndexPath.section) >= self.calendarView.frame.height {
                            self.scrollToHeaderInSection(sectionIndexPath.section, triggerScrollToDateDelegate: triggerScrollToDateDelegate, withAnimation: animateScroll, completionHandler: completionHandler)
                            return
                        } else {
                            scrollToIndexPath(NSIndexPath(forItem: 0, inSection: sectionIndexPath.section), animateScroll)
                        }
                    } else {
                        // If paging is on and header is off, then scroll to the start date in section
                        scrollToIndexPath(NSIndexPath(forItem: 0, inSection: sectionIndexPath.section), animateScroll)
                    }
                } else {
                    // If paging is off, then scroll to the actual date in the section
                    scrollToIndexPath(sectionIndexPath, animateScroll)
                }
                
                // Jt101 put this into a function to reduce code between this and the scroll to header function
                delayRunOnMainThread(0.0, closure: {
                    if  !animateScroll  {
                        self.scrollViewDidEndScrollingAnimation(self.calendarView)
                        self.scrollInProgress = false
                    }
                })
            } else {
                self.scrollInProgress = false
            }
        })
    }
    
    /// Scrolls the calendar view to the start of a section view header. If the calendar has no headers registered, then this function does nothing
    /// - Paramater date: The calendar view will scroll to the header of a this provided date
    public func scrollToHeaderForDate(date: NSDate, triggerScrollToDateDelegate: Bool = false, withAnimation animation: Bool = false, completionHandler: (()->Void)? = nil) {
        let path = pathsFromDates([date])
        // Return if date was incalid and no path was returned
        if path.count < 1 { return }
        scrollToHeaderInSection(path[0].section, triggerScrollToDateDelegate: triggerScrollToDateDelegate, withAnimation: animation, completionHandler: completionHandler)
    }
    
    /// Generates a range of dates from from a startDate to an endDate you provide
    /// Parameter startDate: Start date to generate dates from
    /// Parameter endDate: End date to generate dates to
    /// returns:
    ///     - An array of the successfully generated dates
    public func generateDateRange(from startDate: NSDate, to endDate:NSDate)-> [NSDate] {
        if startDate > endDate { return [] }
        var returnDates: [NSDate] = []
        var currentDate = startDate
        repeat {
            returnDates.append(currentDate)
            currentDate = calendar.startOfDayForDate(calendar.dateByAddingUnit(.Day, value: 1, toDate: currentDate, options: [])!)
        } while currentDate <= endDate
        return returnDates
    }

}
