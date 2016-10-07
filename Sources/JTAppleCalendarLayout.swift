//
//  JTAppleCalendarLayout.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//


/// Base class for the Horizontal layout
open class JTAppleCalendarLayout: UICollectionViewLayout,
                                    JTAppleCalendarLayoutProtocol {
    let errorDelta: CGFloat = 0.0000001
    var itemSize: CGSize = CGSize.zero
    var headerReferenceSize: CGSize = CGSize.zero
    var scrollDirection: UICollectionViewScrollDirection = .horizontal
    var maxSections: Int {
        get {
            return monthMap.count
        }
    }
    var maxMissCount: Int = 0
    var cellCache: [Int: [UICollectionViewLayoutAttributes]] = [:]
    var headerCache: [Int: UICollectionViewLayoutAttributes] = [:]
    var sectionSize: [CGFloat] = []
    var lastWrittenCellAttribute: UICollectionViewLayoutAttributes?
    var thereAreHeaders: Bool {
        get {
            return delegate.registeredHeaderViews.count > 0
        }
    }
    var monthData: [Month] {
        get {
            return delegate.monthInfo
        }
    }
    var monthMap: [Int: Int] {
        get {
            return delegate.monthMap
        }
    }
    var numberOfRows: Int {
        get {
            return delegate.numberOfRows()
        }
    }
    var stride: CGFloat = 0
    weak var delegate: JTAppleCalendarDelegateProtocol!
    var currentHeader: (section: Int, size: CGSize)?
    // Tracks the current header size

    var currentCell: (section: Int, itemSize: CGSize)?
    // Tracks the current cell size

    var contentHeight: CGFloat = 0 // Content height of calendarView
    var contentWidth: CGFloat = 0 // Content wifth of calendarView
    var xCellOffset: CGFloat = 0
    var yCellOffset: CGFloat = 0
    var daysInSection: [Int: Int] = [:] // Caching
    init(withDelegate delegate: JTAppleCalendarDelegateProtocol) {
        super.init()
        self.delegate = delegate
    }

    /// Tells the layout object to update the current layout.
    open override func prepare() {
        print("Prepare was called")
        if !cellCache.isEmpty {
            return
        }
        print("All was recreated!! ")
        maxMissCount = scrollDirection == .horizontal ?
            maxNumberOfRowsPerMonth : maxNumberOfDaysInWeek
        if scrollDirection == .vertical {
            verticalStuff()
        } else {
            horizontalStuff()
        }

        // Get rid of header data if dev didnt register headers.
        // The were used for calculation but are not needed to be displayed
        if !thereAreHeaders {
            headerCache.removeAll()
        }
        daysInSection.removeAll() // Clear chache
    }

    func horizontalStuff() {
        var section = 0
        var rowNumber = 0
        var totalDayCounter = 0
        var headerGuide = 0
        for aMonth in monthData {
            for numberOfDaysInCurrentSection in aMonth.sections {
                // Generate and cache the headers
                let sectionIndexPath = IndexPath(item: 0, section: section)
                if let aHeaderAttr = layoutAttributesForSupplementaryView(
                    ofKind: UICollectionElementKindSectionHeader,
                    at: sectionIndexPath) {
                        headerCache[section] = aHeaderAttr
                        if thereAreHeaders {
                            contentWidth += aHeaderAttr.frame.width
                            yCellOffset = aHeaderAttr.frame.height
                        }
                    }
                // Generate and cache the cells
                for item in 0..<numberOfDaysInCurrentSection {
                    let indexPath = IndexPath(item: item, section: section)
                    if let attribute = deterimeToApplyAttribs(at: indexPath) {
                        if cellCache[section] == nil {
                            cellCache[section] = []
                        }
                        cellCache[section]!.append(attribute)
                        lastWrittenCellAttribute = attribute
                        xCellOffset += attribute.frame.width

                        if thereAreHeaders {
                            headerGuide += 1
                            if numberOfDaysInCurrentSection - 1 == item ||
                                headerGuide % 7 == 0 {
                                // We are at the last item in the section
                                // && if we have headers
                                    headerGuide = 0
                                    xCellOffset = 0
                                    yCellOffset += attribute.frame.height
                            }
                        } else {
                            totalDayCounter += 1
                            if totalDayCounter >= delegate.totalDays {
                                // If we are at the last item and we are
                                // also ona partial (because we were not
                                // at end of row)
                                contentWidth += lastWrittenCellAttribute!
                                    .frame.width * 7
                            } else if totalDayCounter % 7 == 0 {
                                xCellOffset = 0
                                if rowNumber + 1 == numberOfRows {
                                    // If we are at the end of
                                    // a virtual section
                                    yCellOffset = 0
                                    contentWidth += lastWrittenCellAttribute!
                                        .frame.width * 7
                                    stride = contentWidth
                                    rowNumber = 0
                                } else if numberOfDaysInCurrentSection - 1 ==
                                    item {
                                        xCellOffset = 0
                                        yCellOffset = 0
                                        contentWidth +=
                                            lastWrittenCellAttribute!
                                                .frame.width * 7
                                        stride = contentWidth
                                        rowNumber = 0
                                } else {
                                    // We we are simply only at
                                    // the end of a row
                                    yCellOffset += attribute.frame.height
                                    rowNumber += 1
                                }
                            }
                        }
                    }
                }
                // Save the content size for each section
                sectionSize.append(contentWidth)
                if thereAreHeaders {
                    stride = sectionSize[section]
                }
                section += 1
            }
        }
        contentHeight = self.collectionView!.bounds.size.height
    }

    func verticalStuff() {
        var section = 0
        var totalDayCounter = 0
        var headerGuide = 0
        for aMonth in monthData {
            for numberOfDaysInCurrentSection in aMonth.sections {
                // Generate and cache the headers
                let sectionIndexPath = IndexPath(item: 0, section: section)
                if thereAreHeaders {
                    if let aHeaderAttr =
                        layoutAttributesForSupplementaryView(
                            ofKind: UICollectionElementKindSectionHeader,
                            at: sectionIndexPath) {

                        headerCache[section] = aHeaderAttr
                        yCellOffset += aHeaderAttr.frame.height
                        contentHeight += aHeaderAttr.frame.height
                    }
                }
                // Generate and cache the cells
                for item in 0..<numberOfDaysInCurrentSection {
                    let indexPath = IndexPath(item: item, section: section)

                    if let attribute = deterimeToApplyAttribs(at: indexPath) {
                        if cellCache[section] == nil {
                            cellCache[section] = []
                        }
                        cellCache[section]!.append(attribute)
                        lastWrittenCellAttribute = attribute
                        xCellOffset += attribute.frame.width
                        if thereAreHeaders {
                            headerGuide += 1
                            if headerGuide % 7 == 0 ||
                                numberOfDaysInCurrentSection - 1 == item {
                                // We are at the last item in the
                                // section && if we have headers
                                headerGuide = 0
                                xCellOffset = 0
                                yCellOffset += attribute.frame.height
                                contentHeight += attribute.frame.height
                            }
                        } else {
                            totalDayCounter += 1
                            if totalDayCounter % 7 == 0 {
                                xCellOffset = 0
                                yCellOffset += attribute.frame.height
                                contentHeight += attribute.frame.height
                            }
                        }
                    }
                }
                // Save the content size for each section
                sectionSize.append(contentHeight)
                section += 1
            }
        }
        contentWidth = self.collectionView!.bounds.size.width
    }

    /// Returns the width and height of the collection view’s contents.
    /// The width and height of the collection view’s contents.
    open override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    /// Returns the layout attributes for all of the cells
    /// and views in the specified rectangle.
    override open func layoutAttributesForElements(in rect: CGRect) ->
        [UICollectionViewLayoutAttributes]? {
            let startSectionIndex = startIndexFrom(rectOrigin: rect.origin)
            // keep looping until there were no interception rects
            var attributes: [UICollectionViewLayoutAttributes] = []
            var beganIntercepting = false
            var missCount = 0
            for sectionIndex in startSectionIndex..<cellCache.count {
                if let validSection = cellCache[sectionIndex],
                    validSection.count > 0 {
                        // Add header view attributes
                        if thereAreHeaders {
                            if headerCache[sectionIndex]!
                                .frame.intersects(rect) {
                                    attributes
                                        .append(headerCache[sectionIndex]!)
                            }
                        }
                        for val in validSection {
                            if val.frame.intersects(rect) {
                                missCount = 0
                                beganIntercepting = true
                                attributes.append(val)
                            } else {
                                missCount += 1
                                // If there are at least 8 misses in a row
                                // since intercepting began, then this
                                // section has no more interceptions.
                                // So break
                                if missCount > maxMissCount &&
                                    beganIntercepting {
                                    break
                                }
                            }
                        }
                        if missCount > maxMissCount && beganIntercepting {
                            break
                        }// Also break from outter loop
                }
            }
            return attributes
    }

    /// Returns the layout attributes for the item at the specified index
    // path. A layout attributes object containing the information to apply
    // to the item’s cell.
    override open func layoutAttributesForItem(at indexPath: IndexPath) ->
        UICollectionViewLayoutAttributes? {
            // If this index is already cached, then return it else,
            // apply a new layout attribut to it
            if let alreadyCachedCellAttrib = cellCache[indexPath.section],
                indexPath.item < alreadyCachedCellAttrib.count,
                indexPath.item >= 0 {
                    return alreadyCachedCellAttrib[indexPath.item]
            }
            return deterimeToApplyAttribs(at: indexPath)
    }

    func deterimeToApplyAttribs(at indexPath: IndexPath) ->
        UICollectionViewLayoutAttributes? {
            let monthIndex = monthMap[indexPath.section]!
            let numberOfDays = numberOfDaysInSection(monthIndex)
            if !(0...maxSections ~= indexPath.section) ||
                !(0...numberOfDays  ~= indexPath.item) {
                    return nil
            } // return nil on invalid range
            let attr =
                UICollectionViewLayoutAttributes(forCellWith: indexPath)
            applyLayoutAttributes(attr)
            return attr
    }

    /// Returns the layout attributes for the specified supplementary view.
    open override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String, at indexPath: IndexPath) ->
        UICollectionViewLayoutAttributes? {

            let attributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: elementKind, with: indexPath)
            if let alreadyCachedHeaderAttrib =
                headerCache[indexPath.section] {
                    return alreadyCachedHeaderAttrib
            }

            let headerSize = cachedHeaderSizeForSection(indexPath.section)

            switch scrollDirection {
            case .horizontal:
                let modifiedSize = sizeForitemAtIndexPath(indexPath)
                attributes.frame = CGRect(x: contentWidth, y: 0,
                                          width: modifiedSize.width * 7,
                                          height: headerSize.height)
            case .vertical:
                // Use the calculaed header size and force the width
                // of the header to take up 7 columns
                // We cache the header here so we dont call the
                // delegate so much

                let modifiedSize = CGSize(width: collectionView!.frame.width,
                                          height: headerSize.height)
                attributes.frame = CGRect(x: 0, y: yCellOffset,
                                          width: modifiedSize.width,
                                          height: modifiedSize.height)
            }
            if attributes.frame == CGRect.zero {
                return nil
            }
            return attributes
    }

    func applyLayoutAttributes(
        _ attributes: UICollectionViewLayoutAttributes) {
            if attributes.representedElementKind != nil {
                return
            }
            // Calculate the item size
            let size = sizeForitemAtIndexPath(attributes.indexPath)
            attributes.frame = CGRect(
                x: xCellOffset + stride,
                y: yCellOffset,
                width: size.width,
                height: size.height
        )
    }

    func numberOfDaysInSection(_ index: Int) -> Int {
        if let days = daysInSection[index] {
            return days
        }
        let days = monthData[index].numberOfDaysInMonthGrid
        daysInSection[index] = days
        return days
    }

    func cachedHeaderSizeForSection(_ section: Int) -> CGSize {
        // We cache the header here so we dont call the delegate so much
        var headerSize = CGSize.zero
        if let cachedHeader  = currentHeader,
            cachedHeader.section == section {
                headerSize = cachedHeader.size
        } else {
            headerSize = delegate!.referenceSizeForHeaderInSection(section)
            currentHeader = (section, headerSize)
        }
        return headerSize
    }

    func sizeForitemAtIndexPath(_ indexPath: IndexPath) -> CGSize {
        // Return the size if the cell size is already cached
        if let cachedCell  = currentCell,
            cachedCell.section == indexPath.section {
                return cachedCell.itemSize
        }

        var size: CGSize = CGSize.zero
        if let _ = delegate!.itemSize {
            if scrollDirection == .vertical {
                size = itemSize
            } else {
                size.width = itemSize.width
                var headerSize =  CGSize.zero
                if thereAreHeaders {
                    headerSize =
                        cachedHeaderSizeForSection(indexPath.section)
                }

                let currentMonth = monthData[monthMap[indexPath.section]!]
                size.height =
                    (collectionView!.frame.height - headerSize.height) /
                    CGFloat(currentMonth.maxNumberOfRowsForFull(
                        developerSetRows: numberOfRows))
                currentCell = (section: indexPath.section, itemSize: size)
            }
        } else {
        // Get header size if it alrady cached
            var headerSize =  CGSize.zero
            if thereAreHeaders {
                headerSize = cachedHeaderSizeForSection(indexPath.section)
            }
            var height: CGFloat = 0

            let totalNumberOfRows =
                monthData[monthMap[indexPath.section]!].rows
            let currentMonth = monthData[monthMap[indexPath.section]!]
            let monthSection = currentMonth
                .sectionIndexMaps[indexPath.section]!
            let numberOfSections =
                CGFloat(totalNumberOfRows) / CGFloat(numberOfRows)
            let fullSections =  Int(numberOfSections)
            let numberOfRowsForSection: Int
            if scrollDirection == .horizontal {
                numberOfRowsForSection = currentMonth
                    .maxNumberOfRowsForFull(developerSetRows: numberOfRows)
                height = (collectionView!.frame.height - headerSize.height) /
                    CGFloat(numberOfRowsForSection)
            } else {
                if monthSection + 1 <= fullSections {
                    numberOfRowsForSection = numberOfRows
                } else {
                    numberOfRowsForSection = totalNumberOfRows -
                        (monthSection * numberOfRows)
                }
                height = (collectionView!.frame.height - headerSize.height) /
                    CGFloat(numberOfRowsForSection)
            }
            size        = CGSize(width: itemSize.width, height: height)
            currentCell = (section: indexPath.section, itemSize: size)

        }
        return size
    }

    func sizeOfSection(_ section: Int) -> CGFloat {
        switch scrollDirection {
        case .horizontal:
            return cellCache[section]![0].frame.width *
                CGFloat(maxNumberOfDaysInWeek)
        case .vertical:
            let headerSizeOfSection = headerCache.count > 0 ?
                headerCache[section]!.frame.height : 0
            return cellCache[section]![0].frame.height *
                CGFloat(numberOfRowsForMonth(section)) + headerSizeOfSection
        }
    }

    func numberOfRowsForMonth(_ index: Int) -> Int {
        let monthIndex = monthMap[index]!
        return monthData[monthIndex].rows
    }

    func startIndexFrom(rectOrigin offset: CGPoint) -> Int {
        let key =  scrollDirection == .horizontal ? offset.x : offset.y
        return startIndexBinarySearch(sectionSize, offset: key)
    }

    func sizeOfContentForSection(_ section: Int) -> CGFloat {
        return sizeOfSection(section)
    }

    func sectionFromRectOffset(_ offset: CGPoint) -> Int {
        let theOffet = scrollDirection == .horizontal ? offset.x : offset.y
        return sectionFromOffset(theOffet)
    }

    func sectionFromOffset(_ theOffSet: CGFloat) -> Int {
        var val: Int = 0
        for (index, sectionSizeValue) in sectionSize.enumerated() {
            if abs(theOffSet - sectionSizeValue) < errorDelta {
                continue
            }
            if theOffSet < sectionSizeValue {
                val = index
                break
            }
        }
        return val
    }

    func startIndexBinarySearch<T: Comparable>(_ val: [T], offset: T) -> Int {
        if val.count < 3 {
            return 0
        } // If the range is less than 2 just break here.
        var midIndex: Int = 0
        var startIndex = 0
        var endIndex = val.count - 1
        while startIndex < endIndex {
            midIndex = startIndex + (endIndex - startIndex) / 2
            if midIndex + 1  >= val.count || offset >= val[midIndex] &&
                offset < val[midIndex + 1] ||  val[midIndex] == offset {
                    break
            } else if val[midIndex] < offset {
                startIndex = midIndex + 1
            } else {
                endIndex = midIndex
            }
        }
        return midIndex
    }

    /// Returns an object initialized from data in a given unarchiver.
    /// self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Returns the content offset to use after an animation
    /// layout update or change.
    /// - Parameter proposedContentOffset: The proposed point for the
    ///   upper-left corner of the visible content
    /// - returns: The content offset that you want to use instead
    open override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
            return proposedContentOffset
    }

    func clearCache() {
        headerCache.removeAll()
        cellCache.removeAll()
        sectionSize.removeAll()
        currentHeader = nil
        currentCell = nil
        lastWrittenCellAttribute = nil
        xCellOffset = 0
        yCellOffset = 0
        contentHeight = 0
        contentWidth = 0
        stride = 0
    }

}
