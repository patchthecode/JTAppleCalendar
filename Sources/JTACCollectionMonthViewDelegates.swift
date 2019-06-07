//
//  JTACCollectionViewDelegates.swift
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

extension JTACMonthView: UICollectionViewDelegate, UICollectionViewDataSource {
    /// Asks your data source object to provide a
    /// supplementary view to display in the collection view.
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            let validDate = monthInfoFromSection(indexPath.section),
            let delegate = calendarDelegate else {
                developerError(string: "Either date could not be generated or delegate was nil")
                assert(false, "Date could not be generated for section. This is a bug. Contact the developer")
                return UICollectionReusableView()
        }
        
        let headerView = delegate.calendar(self, headerViewForDateRange: validDate.range, at: indexPath)
        headerView.transform.a = semanticContentAttribute == .forceRightToLeft ? -1 : 1
        return headerView
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !pathsToReload.contains(indexPath) { return }
        pathsToReload.remove(indexPath)
        let cellState: CellState
        if let validCachedCellState = selectedCellData[indexPath]?.cellState {
            cellState = validCachedCellState
        } else {
            cellState = cellStateFromIndexPath(indexPath)
        }
        calendarDelegate!.calendar(self, willDisplay: cell as! JTACDayCell, forItemAt: cellState.date, cellState: cellState, indexPath: indexPath)
    }
    
    /// Tells the delegate that the item at the specified index path was highlighted.
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard
            let delegate = calendarDelegate,
            let infoOfDate = dateOwnerInfoFromPath(indexPath) else {
                return
        }
        let cell = collectionView.cellForItem(at: indexPath) as? JTACDayCell
        let cellState = cellStateFromIndexPath(indexPath, withDateInfo: infoOfDate, selectionType: .userInitiated)
        delegate.calendar(self, didHighlightDate: cellState.date, cell: cell, cellState: cellState, indexPath: indexPath)
    }
    
    /// Tells the delegate that the item at the specified index path was unhighlighted.
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard
            let delegate = calendarDelegate,
            let infoOfDate = dateOwnerInfoFromPath(indexPath) else {
                return
        }
        let cell = collectionView.cellForItem(at: indexPath) as? JTACDayCell
        let cellState = cellStateFromIndexPath(indexPath, withDateInfo: infoOfDate, selectionType: .userInitiated)
        delegate.calendar(self, didUnhighlightDate: cellState.date, cell: cell, cellState: cellState, indexPath: indexPath)
    }
    
    /// Asks your data source object for the cell that corresponds
    /// to the specified item in the collection view.
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = calendarDelegate else {
            print("Your delegate does not conform to JTAppleCalendarMonthViewDelegate")
            assert(false)
            return UICollectionViewCell()
        }
        let cellState = cellStateFromIndexPath(indexPath)
        let configuredCell = delegate.calendar(self, cellForItemAt: cellState.date, cellState: cellState, indexPath: indexPath)
        
        pathsToReload.remove(indexPath)
        configuredCell.transform.a = semanticContentAttribute == .forceRightToLeft ? -1 : 1
        return configuredCell
    }
    
    /// Asks your data sourceobject for the number of sections in
    /// the collection view. The number of sections in collectionView.
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return monthMap.count
    }
    
    /// Asks your data source object for the number of items in the
    /// specified section. The number of rows in section.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if calendarViewLayout.cellCache.isEmpty {return 0}
        guard let count =  calendarViewLayout.cellCache[section]?.count else {
            developerError(string: "cellCacheSection does not exist.")
            return 0
        }
        return count
    }
    
    /// Asks the delegate if the specified item should be selected.
    /// true if the item should be selected or false if it should not.
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return handleShouldSelectionValueChange(collectionView, action: .shouldSelect, indexPath: indexPath, selectionType: .userInitiated)
    }
    
    /// Asks the delegate if the specified item should be deselected.
    /// true if the item should be deselected or false if it should not.
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return handleShouldSelectionValueChange(collectionView, action: .shouldDeselect, indexPath: indexPath, selectionType: .userInitiated)
    }

    /// Tells the delegate that the item at the specified index
    /// path was selected. The collection view calls this method when the
    /// user successfully selects an item in the collection view.
    /// It does not call this method when you programmatically
    /// set the selection.
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleSelectionValueChanged(collectionView, action: .didSelect, indexPath: indexPath, selectionType: .userInitiated)
    }
    
    /// Tells the delegate that the item at the specified path was deselected.
    /// The collection view calls this method when the user successfully
    /// deselects an item in the collection view.
    /// It does not call this method when you programmatically deselect items.
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        handleSelectionValueChanged(collectionView, action: .didDeselect, indexPath: indexPath, selectionType: .userInitiated)
    }
    
    public func sizeOfDecorationView(indexPath: IndexPath) -> CGRect {
        guard let size = calendarDelegate?.sizeOfDecorationView(indexPath: indexPath) else { return .zero }
        return size
    }
    
    func handleSelectionValueChanged(_ collectionView: UICollectionView, action: SelectionAction, indexPath: IndexPath, selectionType: SelectionType, shouldTriggerSelectionDelegate: Bool = true) {
        guard
            let delegate = calendarDelegate,
            let infoOfDate = dateOwnerInfoFromPath(indexPath) else {
                return
        }
        // index paths to be reloaded should be index to the left and right of the selected index
        var localPathsToReload: Set<IndexPath> = allowsRangedSelection ? validForwardAndBackwordSelectedIndexes(forIndexPath: indexPath, restrictToSection: false).set : []
        
        let cell = collectionView.cellForItem(at: indexPath) as? JTACDayCell
        if !shouldTriggerSelectionDelegate || cell == nil {
            pathsToReload.insert(indexPath)
            localPathsToReload.insert(indexPath)
        }
        
        let isSelected = action == .didSelect ? true : false
        
        // If cell has a counterpart cell, then select it as well
        let cellState = cellStateFromIndexPath(indexPath, withDateInfo: infoOfDate, cell: cell, isSelected: isSelected, selectionType: selectionType)
        
        // Update model
        let cleanupAction: (IndexPath, Date, DateOwner) -> IndexPath?
        
        if action == .didSelect {
            cleanupAction = selectCounterPartCellIndexPath
            addCellToSelectedSet(indexPath, date: infoOfDate.date, cellState: cellState)
        } else {
            cleanupAction = deselectCounterPartCellIndexPath
            deleteCellFromSelectedSetIfSelected(indexPath)
        }
        
        // check if the paths to reload (forward&backward indexes) also have counterpart dates
        if !localPathsToReload.isEmpty {
            let reloadPaths = localPathsToReload
            for path in reloadPaths {
                if let validCounterPath = selectedCellData[path]?.counterIndexPath {
                    localPathsToReload.insert(validCounterPath)
                }
            }
        }
        
        if let counterPartIndexPath = cleanupAction(indexPath, infoOfDate.date, cellState.dateBelongsTo) {
            localPathsToReload.insert(counterPartIndexPath)
            let counterPathsToReload = allowsRangedSelection ? validForwardAndBackwordSelectedIndexes(forIndexPath: counterPartIndexPath, restrictToSection: false).set : []
            localPathsToReload.formUnion(counterPathsToReload)
        }
        
        setMinMaxDate()
        
        if shouldTriggerSelectionDelegate {
            if action == .didSelect {
                delegate.calendar(self, didSelectDate: infoOfDate.date, cell: cell, cellState: cellState, indexPath: indexPath)
            } else {
                delegate.calendar(self, didDeselectDate: infoOfDate.date, cell: cell, cellState: cellState, indexPath: indexPath)
            }
        }
        
        if !localPathsToReload.isEmpty {
            batchReloadIndexPaths(Array(localPathsToReload))
        }
    }
    
    func setMinMaxDate() {
        let selectedCellData = self.selectedCellData
        let sortedKeys = selectedCellData.keys.sorted()
        guard
            let firstIndex = sortedKeys.first,
            let lastIndex = sortedKeys.last else {
                selectedCells.first = nil
                selectedCells.last = nil
                return
        }
        let date = selectedCellData[firstIndex]!.date
        selectedCells.first = (date, firstIndex)
        selectedCells.last = (date, lastIndex)
    }
    
    func handleShouldSelectionValueChange(_ collectionView: UICollectionView, action: ShouldSelectionAction, indexPath: IndexPath, selectionType: SelectionType) -> Bool {
        if let
            delegate = calendarDelegate,
            let infoOfDate = dateOwnerInfoFromPath(indexPath) {
            let cell = collectionView.cellForItem(at: indexPath) as? JTACDayCell
            let cellState = cellStateFromIndexPath(indexPath,
                                                   withDateInfo: infoOfDate,
                                                   selectionType: selectionType)
            switch action {
            case .shouldSelect:
                return delegate.calendar(self, shouldSelectDate: infoOfDate.date, cell: cell, cellState: cellState, indexPath: indexPath)
            case .shouldDeselect:
                return delegate.calendar(self, shouldDeselectDate: infoOfDate.date, cell: cell, cellState: cellState, indexPath: indexPath)
            }
        }
        return false
    }
}
