//
//  UserInteractionFunctions.swift
//  Pods
//
//  Created by JayT on 2016-05-12.
//
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
        let convertedRow = (row * maxNumberOfDaysInWeek) + column
        let indexPathToFind =
            IndexPath(item: convertedRow, section: currentSectionPage)
        if let date = dateInfoFromPath(indexPathToFind) {
            let stateOfCell =
                cellStateFromIndexPath(indexPathToFind, withDateInfo: date)
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
        if paths.count < 1 {
            return nil
        }
        let cell = calendarView.cellForItem(at: paths[0]) as? JTAppleDayCell
        let stateOfCell = cellStateFromIndexPath(paths[0], cell: cell)
        return stateOfCell
    }

    /// Returns the calendar view's current section boundary dates.
    /// - returns:
    ///     - range: A range containing the startDate and the
    ///              endDaye for the current date segment
    ///     - month: The month that the date range belongs to.
    ///              If you have pre/post dates, this value can be useful
    ///              to know which month it belongs to.
    public func dateSegment() -> (range: (start: Date, end: Date),
                                  month: Int, rowsForSection: Int) {
        guard dataSource != nil, let dateSegment =
            monthInfoFromSection(currentSectionPage) else {
                if dataSource == nil {
                    print("Error: DataSource not yet set")
                }
                return (range: (start: Date(), end: Date()),
                        month: 0, rowsForSection: 0)
        }
        return dateSegment
    }

    /// Let's the calendar know which cell xib to
    /// use for the displaying of it's date-cells.
    /// - Parameter name: The name of the xib of your cell design
    /// - Parameter bundle: The bundle where the xib can be found.
    ///                     If left nil, the library will search the
    ///                     main bundle
    public func registerCellViewXib(file name: String,
                                    bundle: Bundle? = nil) {
        cellViewSource = JTAppleCalendarViewSource.fromXib(name, bundle)
    }

    /// Let's the calendar know which cell class to use
    /// for the displaying of it's date-cells.
    /// - Parameter name: The class name of your cell design
    /// - Parameter bundle: The bundle where the xib can be found.
    ///                     If left nil, the library will search the
    ///                     main bundle
    public func registerCellViewClass(file name: String,
                                      bundle: Bundle? = nil) {
        cellViewSource =
            JTAppleCalendarViewSource.fromClassName(name, bundle)
    }

    /// Let's the calendar know which cell
    /// class to use for the displaying of it's date-cells.
    /// - Parameter name: The type of your cell design
    public func registerCellViewClass(type: AnyClass) {
        cellViewSource = JTAppleCalendarViewSource.fromType(type)
    }

    /// Register header views with the calender. This needs to be done
    /// before the view can be displayed
    /// - Parameter fileNames: A dictionary containing
    ///                        [headerViewNames:HeaderviewSizes]
    /// - Parameter bundle: The bundle where the xibs can be found.
    ///                     If left nil, the library will search the
    ///                     main bundle
    public func registerHeaderView(xibFileNames: [String],
                                   bundle: Bundle? = nil) {
        if xibFileNames.count < 1 {
        return
    }
        unregisterHeaders()
        for headerViewXibName in xibFileNames {
            registeredHeaderViews.append(JTAppleCalendarViewSource
                .fromXib(headerViewXibName, bundle))
            self.calendarView.register(
                JTAppleCollectionReusableView.self,
                forSupplementaryViewOfKind:
                    UICollectionElementKindSectionHeader,
                withReuseIdentifier: headerViewXibName
            )
        }
    }

    /// Register header views with the calender. This needs to be
    /// done before header views can be displayed
    /// - Parameter fileNames: A dictionary containing
    ///                        [headerViewNames:HeaderviewSizes]
    /// - Parameter bundle: The bundle where the xibs can be found. If left
    ///                     nil, the library will search the main bundle
    public func registerHeaderView(classStringNames: [String],
                                   bundle: Bundle? = nil) {
        if classStringNames.count < 1 {
            return
        }
        unregisterHeaders()
        for headerViewClassName in classStringNames {
            registeredHeaderViews.append(JTAppleCalendarViewSource
                .fromClassName(headerViewClassName, bundle))
            self.calendarView.register(
                JTAppleCollectionReusableView.self,
                forSupplementaryViewOfKind:
                    UICollectionElementKindSectionHeader,
                withReuseIdentifier: headerViewClassName
            )
        }
    }

    /// Register header views with the calender. This needs to be done
    /// before header views can be displayed
    /// - Parameter fileNames: A dictionary containing
    ///                        [headerViewNames:HeaderviewSizes]
    public func registerHeaderView(classTypeNames: [AnyClass]) {
        if classTypeNames.count < 1 {
            return
        }
        unregisterHeaders()
        for aClass in classTypeNames {
            registeredHeaderViews
                .append(JTAppleCalendarViewSource.fromType(aClass))
            self.calendarView.register(
                JTAppleCollectionReusableView.self,
                forSupplementaryViewOfKind:
                    UICollectionElementKindSectionHeader,
                    withReuseIdentifier: aClass.description()
            )
        }
    }

    /// Unregister previously registered headers
    public func unregisterHeaders() {
        registeredHeaderViews.removeAll()
        // remove the already registered xib
        // files if the user re-registers again.
        layoutNeedsUpdating = true
    }

    /// Reloads the data on the calendar view. Scroll delegates are not
    //  triggered with this function.
    /// - Parameter date: An anchordate that the calendar will
    ///                   scroll to after reload completes
    /// - Parameter animation: Scroll is animated if this is set to true
    /// - Parameter completionHandler: This closure will run after
    ///                                the reload is complete
    public func reloadData(withAnchor date: Date? = nil,
                           animation: Bool = false,
                           completionHandler: (() -> Void)? = nil) {
        if !calendarIsAlreadyLoaded {
            return
        }
        reloadData(checkDelegateDataSource: true,
                   withAnchorDate: date,
                   withAnimation: animation,
                   completionHandler: completionHandler)
    }

    /// Reload the date of specified date-cells on the calendar-view
    /// - Parameter dates: Date-cells with these specified
    ///                    dates will be reloaded
    public func reloadDates(_ dates: [Date]) {
        var paths = [IndexPath]()
        for date in dates {
            let aPath = pathsFromDates([date])
            paths.append(contentsOf: aPath)
            if aPath.count > 0 {
                let cellState = cellStateFromIndexPath(aPath[0])
                if let validCounterPartCell =
                    indexPathOfdateCellCounterPart(
                        date,
                        indexPath: aPath[0],
                        dateOwner: cellState.dateBelongsTo) {
                    paths.append(validCounterPartCell)
                }
            }
        }
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
    public func selectDates(
        from startDate: Date, to endDate: Date,
        triggerSelectionDelegate: Bool = true,
        keepSelectionIfMultiSelectionAllowed: Bool = false) {
            selectDates(generateDateRange(from: startDate, to: endDate),
                        triggerSelectionDelegate: triggerSelectionDelegate,
                        keepSelectionIfMultiSelectionAllowed:
                            keepSelectionIfMultiSelectionAllowed)
    }

    public func deselectAllDates(triggerSelectionDelegate: Bool = true) {
        selectDates(selectedDates,
                    triggerSelectionDelegate: triggerSelectionDelegate)
    }

    /// Select a date-cells
    /// - Parameter date: The date-cell with this date will be selected
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function
    ///    only if the value is set to true.
    /// Sometimes it is necessary to setup some dates without triggereing
    /// the delegate e.g. For instance, when youre initally setting up data
    /// in your viewDidLoad
    public func selectDates(
        _ dates: [Date],
        triggerSelectionDelegate: Bool = true,
        keepSelectionIfMultiSelectionAllowed: Bool = false) {
            if !calendarIsAlreadyLoaded {
                // If the calendar is nnot yet fully loaded.
                // Add the task to the delayed queue
                delayedExecutionClosure.append {
                    self.selectDates(
                        dates,
                        triggerSelectionDelegate: triggerSelectionDelegate,
                        keepSelectionIfMultiSelectionAllowed:
                            keepSelectionIfMultiSelectionAllowed
                    )
                }
                return
        }
        var allIndexPathsToReload: [IndexPath] = []
        var validDatesToSelect = dates
        // If user is trying to select multiple dates with
        // multiselection disabled, then only select the last object
        if !calendarView.allowsMultipleSelection && dates.count > 0 {
            validDatesToSelect = [dates.last!]
        }
        let addToIndexSetToReload = { (indexPath: IndexPath) -> Void in
            if !allIndexPathsToReload.contains(indexPath) {
                allIndexPathsToReload.append(indexPath)
            } // To avoid adding the  same indexPath twice.
        }

        let selectTheDate = {
            (indexPath: IndexPath, date: Date) -> Void in
            self.calendarView.selectItem(at: indexPath,
                                         animated: false, scrollPosition: [])
            addToIndexSetToReload(indexPath)
            // If triggereing is enabled, then let their delegate
            // handle the reloading of view, else we will reload the data
            if triggerSelectionDelegate {
                self.internalCollectionView(
                    self.calendarView, didSelectItemAtIndexPath: indexPath)
            } else {
                // Although we do not want the delegate triggered, we
                // still want counterpart cells to be selected
                // Because there is no triggering of the delegate, the cell
                // will not be added to selection and it will not be
                // reloaded. We need to do this here
                self.addCellToSelectedSetIfUnselected(indexPath, date: date)
                let cellState = self.cellStateFromIndexPath(indexPath)
                // , withDateInfo: date)
                if let aSelectedCounterPartIndexPath =
                    self.selectCounterPartCellIndexPathIfExists(
                        indexPath,
                        date: date,
                        dateOwner: cellState.dateBelongsTo) {
                            // If there was a counterpart cell then
                            // it will also need to be reloaded
                            addToIndexSetToReload(
                                aSelectedCounterPartIndexPath
                            )
                }
            }
        }
        let deSelectTheDate = { (oldIndexPath: IndexPath) -> Void in
            addToIndexSetToReload(oldIndexPath)
            if let index = self.theSelectedIndexPaths
                .index(of: oldIndexPath) {
                    let oldDate = self.theSelectedDates[index]
                    self.calendarView.deselectItem(at: oldIndexPath,
                                                   animated: false)
                    self.theSelectedIndexPaths.remove(at: index)
                    self.theSelectedDates.remove(at: index)
                    // If delegate triggering is enabled, let the
                    // delegate function handle the cell
                    if triggerSelectionDelegate {
                        self.internalCollectionView(self.calendarView,
                            didDeselectItemAtIndexPath: oldIndexPath)
                    } else {
                        // Although we do not want the delegate triggered,
                        // we still want counterpart cells to be deselected
                        let cellState =
                            self.cellStateFromIndexPath(oldIndexPath)
                                // , withDateInfo: oldDate)
                        if let anUnselectedCounterPartIndexPath =
                            self.deselectCounterPartCellIndexPath(
                                oldIndexPath, date: oldDate,
                                dateOwner: cellState.dateBelongsTo) {
                                    // If there was a counterpart cell then
                                    // it will also need to be reloaded
                                    addToIndexSetToReload(
                                        anUnselectedCounterPartIndexPath
                                    )
                        }
                    }
            }
        }
        for date in validDatesToSelect {
            let components = self.calendar
                .dateComponents([.year, .month, .day], from: date)
            let firstDayOfDate = self.calendar.date(from: components)!
            // If the date is not within valid boundaries, then exit
            if !(firstDayOfDate >= self.startOfMonthCache &&
                firstDayOfDate <= self.endOfMonthCache) {
                    continue
            }
            let pathFromDates = self.pathsFromDates([date])
            // If the date path youre searching for, doesnt exist, return
            if pathFromDates.count < 0 {
                continue
            }
            let sectionIndexPath = pathFromDates[0]
            // Remove old selections
            if self.calendarView.allowsMultipleSelection == false {
                // If single selection is ON
                let selectedIndexPaths = self.theSelectedIndexPaths
                // made a copy because the array is about to be mutated
                for indexPath in selectedIndexPaths {
                    if indexPath != sectionIndexPath {
                        deSelectTheDate(indexPath)
                    }
                }
                // Add new selections
                // Must be added here. If added in delegate
                // didSelectItemAtIndexPath
                selectTheDate(sectionIndexPath, date)
            } else {
                // If multiple selection is on. Multiple selection behaves
                // differently to singleselection.
                // It behaves like a toggle. unless
                // keepSelectionIfMultiSelectionAllowed is true.
                // If user wants to force selection if multiselection
                // is enabled, then removed the selected dates from
                // generated dates
                if keepSelectionIfMultiSelectionAllowed {
                    if selectedDates.contains(
                        calendar.startOfDay(for: date)) {
                            addToIndexSetToReload(sectionIndexPath)
                            continue
                            // Do not deselect or select the cell.
                            // Just add it to be reloaded
                    }
                }
                if self.theSelectedIndexPaths.contains(sectionIndexPath) {
                    // If this cell is already selected, then deselect it
                    deSelectTheDate(sectionIndexPath)
                } else {
                    // Add new selections
                    // Must be added here. If added in delegate
                    // didSelectItemAtIndexPath
                    selectTheDate(sectionIndexPath, date)
                }
            }
        }
        // If triggering was false, although the selectDelegates weren't
        // called, we do want the cell refreshed.
        // Reload to call itemAtIndexPath
        if triggerSelectionDelegate == false &&
            allIndexPathsToReload.count > 0 {
                delayRunOnMainThread(0.0) {
                    self.batchReloadIndexPaths(allIndexPathsToReload)
                }
        }
    }

    /// Scrolls the calendar view to the next section view. It will
    // execute a completion handler at the end of scroll animation
    // if provided.
    /// - Paramater animateScroll: Bool indicating if animation
    ///   should be enabled
    /// - Parameter triggerScrollToDateDelegate:
    ///   Trigger delegate if set to true
    /// - Parameter completionHandler: A completion handler that
    ///   will be executed at the end of the scroll animation
    public func scrollToNextSegment(
        _ triggerScrollToDateDelegate: Bool = false,
        animateScroll: Bool = true,
        completionHandler: (() -> Void)? = nil) {
            let page = currentSectionPage + 1
            if page < monthInfo.count {
                scrollToSection(
                    page,
                    triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                    animateScroll: animateScroll,
                    completionHandler: completionHandler
                )
            }
    }

    /// Scrolls the calendar view to the previous section view. It will
    /// execute a completion handler at the end of scroll animation if
    /// provided.
    /// - Parameter triggerScrollToDateDelegate: Trigger delegate if set
    ///   to true
    /// - Paramater animateScroll: Bool indicating if animation should
    ///   be enabled
    /// - Parameter completionHandler: A completion handler that will be
    ///   executed at the end of the scroll animation
    public func scrollToPreviousSegment(
        _ triggerScrollToDateDelegate: Bool = false,
        animateScroll: Bool = true,
        completionHandler: (() -> Void)? = nil) {
            let page = currentSectionPage - 1
            if page > -1 {
                scrollToSection(
                    page,
                    triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                    animateScroll: animateScroll,
                    completionHandler: completionHandler
                )
            }
    }

    /// Scrolls the calendar view to the start of a section view containing
    /// a specified date.
    /// - Paramater date: The calendar view will scroll to a date-cell
    ///   containing this date if it exists
    /// - Parameter triggerScrollToDateDelegate: Trigger delegate if set to
    ///   true
    /// - Paramater animateScroll: Bool indicating if animation should be
    ///   enabled
    /// - Paramater preferredScrollPositionIndex: Integer indicating the end
    ///   scroll position on the screen.
    /// This value indicates column number for Horizontal scrolling and row
    /// number for a vertical scrolling calendar
    /// - Parameter completionHandler: A completion handler that will be
    ///   executed at the end of the scroll animation
    public func scrollToDate(
        _ date: Date,
        triggerScrollToDateDelegate: Bool = true,
        animateScroll: Bool = true,
        preferredScrollPosition: UICollectionViewScrollPosition? = nil,
        completionHandler: (() -> Void)? = nil) {
            if !calendarIsAlreadyLoaded {
                delayedExecutionClosure.append {
                    self.scrollToDate(
                        date,
                        triggerScrollToDateDelegate:
                            triggerScrollToDateDelegate,
                        animateScroll: animateScroll,
                        preferredScrollPosition: preferredScrollPosition,
                        completionHandler: completionHandler)
                }
                return
        }

        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        let components =
            calendar.dateComponents([.year, .month, .day], from: date)
        let firstDayOfDate = calendar.date(from: components)!
        scrollInProgress = true
        delayRunOnMainThread(0.0, closure: {
            // This part should be inside the mainRunLoop
            if !(firstDayOfDate >= self.startOfMonthCache &&
                firstDayOfDate <= self.endOfMonthCache) {
                    self.scrollInProgress = false
                    return
            }
            let retrievedPathsFromDates = self.pathsFromDates([date])
            if retrievedPathsFromDates.count > 0 {
                let sectionIndexPath =  self.pathsFromDates([date])[0]
                var position: UICollectionViewScrollPosition =
                    self.direction == .horizontal ? .left : .top
                if !self.scrollingMode.pagingIsEnabled() {
                    if let validPosition = preferredScrollPosition {
                        if self.direction == .horizontal {
                            if validPosition == .left ||
                                validPosition == .right ||
                                validPosition == .centeredHorizontally {
                                    position = validPosition
                            } else {
                                position = .left
                            }
                        } else {
                            if validPosition == .top ||
                                validPosition == .bottom ||
                                validPosition == .centeredVertically {
                                    position = validPosition
                            } else {
                                position = .top
                            }
                        }
                    }
                }
                let scrollToIndexPath = {
                    (iPath: IndexPath, withAnimation: Bool) -> Void in
                    if let validCompletionHandler = completionHandler {
                        self.delayedExecutionClosure
                            .append(validCompletionHandler)
                    }
                    // regular movement
                    self.calendarView.scrollToItem(at: iPath,
                                                   at: position,
                                                   animated: animateScroll)
                    if animateScroll {
                        if let check = self
                            .calendarOffsetIsAlreadyAtScrollPosition(
                                forIndexPath: iPath), check == true {
                                    self.scrollViewDidEndScrollingAnimation(
                                        self.calendarView
                                    )
                                    self.scrollInProgress = false
                                    return
                        }
                    }
                }
                if self.scrollingMode.pagingIsEnabled() {
                    if self.registeredHeaderViews.count > 0 {
                        // If both paging and header is on, then scroll to
                        // the actual date
                        // If direction is vertical and user has a custom
                        // size that is at least the size of the
                        // collectionview.
                        // If this check is not done, it will scroll to
                        // header, and have white space at bottom because
                        // view is smaller due to small custom user itemSize
                        if self.direction == .vertical &&
                            self.calendarViewLayout
                                .sizeOfSection(sectionIndexPath.section) >=
                                    self.calendarView.frame.height {

                            self.scrollToHeaderInSection(
                                sectionIndexPath.section,
                                triggerScrollToDateDelegate:
                                    triggerScrollToDateDelegate,
                                withAnimation: animateScroll,
                                completionHandler: completionHandler
                            )
                            return
                        } else {
                            scrollToIndexPath(
                                IndexPath(
                                    item: 0,
                                    section: sectionIndexPath.section
                                ),
                                animateScroll
                            )
                        }
                    } else {
                        // If paging is on and header is off,
                        // then scroll to the start date in section
                        scrollToIndexPath(
                            IndexPath(
                                item: 0,
                                section: sectionIndexPath.section
                            ),
                            animateScroll
                        )
                    }
                } else {
                    // If paging is off, then scroll to the
                    // actual date in the section
                    scrollToIndexPath(sectionIndexPath, animateScroll)
                }
                // Jt101 put this into a function to reduce code between
                // this and the scroll to header function
                delayRunOnMainThread(0.0, closure: {
                    if  !animateScroll {
                        self.scrollViewDidEndScrollingAnimation(
                            self.calendarView
                        )
                        self.scrollInProgress = false
                    }
                })
            } else {
                self.scrollInProgress = false
            }
        })
    }

    /// Scrolls the calendar view to the start of a section view header.
    // If the calendar has no headers registered, then this function does
    // nothing
    /// - Paramater date: The calendar view will scroll to the header of
    // a this provided date
    public func scrollToHeaderForDate(
        _ date: Date, triggerScrollToDateDelegate: Bool = false,
        withAnimation animation: Bool = false,
        completionHandler: (() -> Void)? = nil) {
            let path = pathsFromDates([date])
            // Return if date was incalid and no path was returned
            if path.count < 1 {
                return
            }
            scrollToHeaderInSection(
                path[0].section,
                triggerScrollToDateDelegate: triggerScrollToDateDelegate,
                withAnimation: animation,
                completionHandler: completionHandler
        )
    }

    /// Generates a range of dates from from a startDate to an
    /// endDate you provide
    /// Parameter startDate: Start date to generate dates from
    /// Parameter endDate: End date to generate dates to
    /// returns:
    ///     - An array of the successfully generated dates

    public func generateDateRange(from startDate: Date,
                                  to endDate: Date) -> [Date] {
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

}
