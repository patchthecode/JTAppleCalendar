//
//  InternalQueryFunctions.swift
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
    
    func targetPointForItemAt(indexPath: IndexPath) -> CGPoint? {
        guard let targetCellFrame = calendarViewLayout.layoutAttributesForItem(at: indexPath)?.frame else { // Jt101 This was changed !!
            return nil
        }
        
        let theTargetContentOffset: CGFloat = scrollDirection == .horizontal ? targetCellFrame.origin.x : targetCellFrame.origin.y
        var fixedScrollSize: CGFloat = 0
        switch scrollingMode {
        case .stopAtEachSection, .stopAtEachCalendarFrame, .nonStopToSection:
            if scrollDirection == .horizontal || (scrollDirection == .vertical && !calendarViewLayout.thereAreHeaders) {
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
        
        var section = theTargetContentOffset / fixedScrollSize
        let roundedSection = round(section)
        if abs(roundedSection - section) < errorDelta { section = roundedSection }
        section = CGFloat(Int(section))
        
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
    
    func indexPathOfdateCellCounterPath(_ date: Date, dateOwner: DateOwner) -> IndexPath? {
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
                
                let numberOfItemsInSection = collectionView(self, numberOfItemsInSection: section)
                guard numberOfItemsInSection > 0 else {
                    assert(false, "Number of sections in calendar = 0. Possible fixes (1) is your calendar visible size 0,0? (2) is your calendar already loaded/visible?")
                    return nil
                }
                let extraSection = itemIndex / numberOfItemsInSection
                let extraIndex = itemIndex % numberOfItemsInSection
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
            
            let dateBefore = self.cachedConfiguration.calendar.date(byAdding: .day, value: -1, to: date)!
            let dateAfter = self.cachedConfiguration.calendar.date(byAdding: .day, value: 1, to: date)!
            
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
    
    func datesAtCurrentOffset(_ offset: CGPoint? = nil) -> DateSegmentInfo {
        
        let rect: CGRect?
        if let offset = offset {
            rect = CGRect(x: offset.x, y: offset.y, width: frame.width, height: frame.height)
        } else {
            rect = nil
        }
        
        let emptySegment = DateSegmentInfo(indates: [], monthDates: [], outdates: [])
        
        if !isCalendarLayoutLoaded {
            return emptySegment
        }
        
        let cellAttributes = calendarViewLayout.elementsAtRect(excludeHeaders: true, from: rect)
        let indexPaths: [IndexPath] = cellAttributes.map { $0.indexPath }.sorted()
        return dateSegmentInfoFrom(visible: indexPaths)
    }
}
