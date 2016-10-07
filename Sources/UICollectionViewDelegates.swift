//
//  UICollectionViewDelegates.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-10-02.
//
//

extension JTAppleCalendarView: UICollectionViewDelegate,
                               UICollectionViewDataSource {

    /// Asks your data source object to provide a
    /// supplementary view to display in the collection view.
    public func collectionView(_ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {

            guard let validDate =
                monthInfoFromSection(indexPath.section) else {
                    assert(false,
                        "Date could not be generated fro section. " +
                        "This is a bug. Contact the developer")
                    return UICollectionReusableView()
            }
            let reuseIdentifier: String
            var source: JTAppleCalendarViewSource = registeredHeaderViews[0]
            // Get the reuse identifier and index
            if registeredHeaderViews.count == 1 {
                switch registeredHeaderViews[0] {
                case let .fromXib(xibName, _):
                    reuseIdentifier = xibName
                case let .fromClassName(className, _):
                    reuseIdentifier = className
                case let .fromType(classType):
                    reuseIdentifier = classType.description()
                }
            } else {
                reuseIdentifier = delegate!.calendar(
                    self,
                    sectionHeaderIdentifierFor: validDate.range,
                    belongingTo: validDate.month)
                for item in registeredHeaderViews {
                    switch item {
                    case let .fromXib(xibName, _) where
                        xibName == reuseIdentifier:
                        source = item
                        break
                    case let .fromClassName(className, _) where
                        className == reuseIdentifier:
                        source = item
                        break
                    case let .fromType(type) where
                        type.description() == reuseIdentifier:
                        source = item
                        break
                    default:
                        continue
                    }
                }
            }
            guard let headerView = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: reuseIdentifier,
                    for: indexPath) as? JTAppleCollectionReusableView else {
                        developerError(string: "Headerview is not of type " +
                            "'JTAppleCollectionReusableView'.")
                        return UICollectionReusableView()
            }
            headerView.setupView(source)
            headerView.update()
            self.delegate?.calendar(
                self,
                willDisplaySectionHeader: headerView.view!,
                range: validDate.range,
                identifier: reuseIdentifier)
            return headerView
    }

    public func collectionView(_ collectionView: UICollectionView,
                               didEndDisplaying cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        guard #available(iOS 10, *) else {
            guard
                let theCell = cell as? JTAppleDayCell,
                let cellView = theCell.view else {
                    developerError(string: "Cell view was nil")
                    return
            }
            self.delegate?.calendar(self, willResetCell: cellView)
            return
        }
    }

    /// Asks your data source object for the cell that corresponds
    /// to the specified item in the collection view.
    public func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            restoreSelectionStateForCellAtIndexPath(indexPath)
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: cellReuseIdentifier,
                for: indexPath) as? JTAppleDayCell else {
                    developerError(string:
                        "Cell was not of type JTAppleDayCell")
                    return UICollectionViewCell()
            }
            cell.setupView(cellViewSource)
            cell.updateCellView(cellInset.x, cellInsetY: cellInset.y)
            cell.bounds.origin = CGPoint(x: 0, y: 0)
            let cellState = cellStateFromIndexPath(indexPath)
            delegate?.calendar(self, willDisplayCell:
                cell.view!, date: cellState.date, cellState: cellState)

            return cell
    }

    /// Asks your data sourceobject for the number of sections in
    /// the collection view. The number of sections in collectionView.
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return monthMap.count
    }


    /// Asks your data source object for the number of items in the
    /// specified section. The number of rows in section.
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        guard let count =  calendarViewLayout.cellCache[section]?.count else {
                developerError(string: "cellCacheSection does not exist.")
                return 0
        }

        return count
    }

    /// Asks the delegate if the specified item should be selected.
    /// true if the item should be selected or false if it should not.
    public func collectionView(_ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath) -> Bool {
            if let
                delegate = self.delegate,
                let infoOfDateUserSelected = dateInfoFromPath(indexPath),
                let cell = collectionView
                    .cellForItem(at: indexPath) as? JTAppleDayCell,
                cellWasNotDisabledOrHiddenByTheUser(cell) {
                let cellState = cellStateFromIndexPath(indexPath,
                    withDateInfo: infoOfDateUserSelected)
                return delegate.calendar(
                    self,
                    canSelectDate: infoOfDateUserSelected.date,
                    cell: cell.view!,
                    cellState: cellState
                )
            }
            return false
    }

    func cellWasNotDisabledOrHiddenByTheUser(_ cell: JTAppleDayCell) -> Bool {
        return cell.view!.isHidden == false &&
            cell.view!.isUserInteractionEnabled == true
    }

    /// Tells the delegate that the item at the specified path was deselected.
    /// The collection view calls this method when the user successfully
    /// deselects an item in the collection view.
    /// It does not call this method when you programmatically deselect items.
    public func collectionView(_ collectionView: UICollectionView,
                               didDeselectItemAt indexPath: IndexPath) {
        let indexPathsToBeReloaded = rangeSelectionWillBeUsed ?
            validForwardAndBackwordSelectedIndexes(forIndexPath: indexPath) :
            [IndexPath]()
        internalCollectionView(collectionView,
                               didDeselectItemAtIndexPath: indexPath,
                               indexPathsToReload: indexPathsToBeReloaded)
    }

    func internalCollectionView(_ collectionView: UICollectionView,
        didDeselectItemAtIndexPath indexPath: IndexPath,
        indexPathsToReload: [IndexPath] = []) {
            if let
                delegate = self.delegate,
                let dateInfoDeselectedByUser = dateInfoFromPath(indexPath) {
                // Update model
                deleteCellFromSelectedSetIfSelected(indexPath)
                let selectedCell = collectionView
                    .cellForItem(at: indexPath) as? JTAppleDayCell
                // Cell may be nil if user switches month sections
                // Although the cell may be nil, we still want to
                // return the cellstate
                let cellState = cellStateFromIndexPath(
                    indexPath,
                    withDateInfo: dateInfoDeselectedByUser,
                    cell: selectedCell
                )
                var pathsToReload = indexPathsToReload
                let deselectCPCell = deselectCounterPartCellIndexPath(
                        indexPath,
                        date: dateInfoDeselectedByUser.date,
                        dateOwner: cellState.dateBelongsTo)
                if let unselectedCounterPartIndexPath = deselectCPCell {
                    deleteCellFromSelectedSetIfSelected(
                        unselectedCounterPartIndexPath)
                    // ONLY if the counterPart cell is visible,
                    // then we need to inform the delegate
                    if !pathsToReload
                        .contains(unselectedCounterPartIndexPath) {
                            pathsToReload
                                .append(unselectedCounterPartIndexPath)
                    }
                }
                if pathsToReload.count > 0 {
                    delayRunOnMainThread(0.0) {
                        self.batchReloadIndexPaths(pathsToReload)
                    }
                }
                delegate.calendar(
                    self,
                    didDeselectDate: dateInfoDeselectedByUser.date,
                    cell: selectedCell?.view,
                    cellState: cellState
                )
            }
    }

    /// Asks the delegate if the specified item should be deselected.
    /// true if the item should be deselected or false if it should not.
    public func collectionView(_ collectionView: UICollectionView,
        shouldDeselectItemAt indexPath: IndexPath) -> Bool {
            if let
                delegate = self.delegate,
                let infoOfDateDeSelectedByUser = dateInfoFromPath(indexPath),
                let cell = collectionView
                    .cellForItem(at: indexPath) as? JTAppleDayCell,
                cellWasNotDisabledOrHiddenByTheUser(cell) {
                let cellState = cellStateFromIndexPath(indexPath,
                    withDateInfo: infoOfDateDeSelectedByUser)
                return delegate.calendar(
                    self,
                    canDeselectDate: infoOfDateDeSelectedByUser.date,
                    cell: cell.view!,
                    cellState: cellState
                )
            }
            return false
    }

    /// Tells the delegate that the item at the specified index
    /// path was selected. The collection view calls this method when the
    /// user successfully selects an item in the collection view.
    /// It does not call this method when you programmatically
    /// set the selection.
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        // index paths to be reloaded should be index
        // to the left and right of the selected index
        let indexPathsToBeReloaded = rangeSelectionWillBeUsed ?
            validForwardAndBackwordSelectedIndexes(forIndexPath: indexPath) :
            [IndexPath]()
        internalCollectionView(collectionView,
                               didSelectItemAtIndexPath: indexPath,
                               indexPathsToReload: indexPathsToBeReloaded)
    }

    func internalCollectionView(_ collectionView: UICollectionView,
                                didSelectItemAtIndexPath indexPath: IndexPath,
                                indexPathsToReload: [IndexPath] = []) {
        guard let delegate = self.delegate,
            let infoOfDateSelectedByUser = dateInfoFromPath(indexPath) else {
                return
        }
        // Update model
        addCellToSelectedSetIfUnselected(indexPath,
                                         date: infoOfDateSelectedByUser.date)
        let selectedCell = collectionView
            .cellForItem(at: indexPath) as? JTAppleDayCell
        // If cell has a counterpart cell, then select it as well
        let cellState = cellStateFromIndexPath(indexPath,
            withDateInfo: infoOfDateSelectedByUser, cell: selectedCell)
        var pathsToReload = indexPathsToReload
        if let selectedCounterPartIndexPath =
            selectCounterPartCellIndexPathIfExists(indexPath,
                date: infoOfDateSelectedByUser.date,
                dateOwner: cellState.dateBelongsTo) {
                    // ONLY if the counterPart cell is visible,
                    // then we need to inform the delegate
                    if !pathsToReload.contains(selectedCounterPartIndexPath) {
                        pathsToReload.append(selectedCounterPartIndexPath)
                    }
        }
        if pathsToReload.count > 0 {
            delayRunOnMainThread(0.0) {
                self.batchReloadIndexPaths(pathsToReload)
            }
        }
        delegate.calendar(
            self,
            didSelectDate: infoOfDateSelectedByUser.date,
            cell: selectedCell?.view,
            cellState: cellState
        )

        print("columns: \(cellStateFromIndexPath(indexPath).column()) " +
            "row: \(cellStateFromIndexPath(indexPath).row())")

    }

}
