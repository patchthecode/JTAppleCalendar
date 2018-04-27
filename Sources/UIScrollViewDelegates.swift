//
//  UIScrollViewDelegates.swift
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

struct ScrollData {
    let contentSizeEndOffset: CGFloat
    var contentOffset: CGFloat
    var theTargetContentOffset: CGFloat
    var directionVelocity: CGFloat
    let isScrollingForward: Bool
    var resistance: CGFloat = 0
}

enum ScrolledDirection {
    case forward, backward
}

extension JTAppleCalendarView: UIScrollViewDelegate {
    /// Inform the scrollViewDidEndDecelerating
    /// function that scrolling just occurred
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(self)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDraggBeginningPoint = scrollDirection == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
    }
    
    /// Tells the delegate when the user finishes scrolling the content.
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let theCurrentSection = currentSection() else { return }
        
        self.decelerationRate = UIScrollViewDecelerationRateNormal
        
        let contentSizeEndOffset: CGFloat
        var contentOffset: CGFloat = 0,
        theTargetContentOffset: CGFloat = 0,
        directionVelocity: CGFloat = 0
        let calendarLayout = calendarViewLayout
        if scrollDirection == .horizontal {
            contentOffset = scrollView.contentOffset.x
            theTargetContentOffset = targetContentOffset.pointee.x
            directionVelocity = velocity.x
            contentSizeEndOffset = scrollView.contentSize.width - scrollView.frame.width
        } else {
            contentOffset = scrollView.contentOffset.y
            theTargetContentOffset = targetContentOffset.pointee.y
            directionVelocity = velocity.y
            contentSizeEndOffset = scrollView.contentSize.height - scrollView.frame.height
        }
        
        let scrollData = ScrollData(contentSizeEndOffset: contentSizeEndOffset,
                                    contentOffset: contentOffset,
                                    theTargetContentOffset: theTargetContentOffset,
                                    directionVelocity: directionVelocity,
                                    isScrollingForward: directionVelocity > 0 ||  contentOffset > self.scrollDraggBeginningPoint,
                                    resistance: 0)
        
        // If no scrolling is occuring
        if contentOffset == scrollDraggBeginningPoint {
            return
        }
        
        let setTargetContentOffset = {(finalOffset: CGFloat) -> Void in
            if self.scrollDirection == .horizontal {
                targetContentOffset.pointee.x = finalOffset
            } else {
                targetContentOffset.pointee.y = finalOffset
            }
            self.endScrollTargetLocation = finalOffset
        }
        
//        if didEndScollCount > 0, directionVelocity == 0, scrollingMode != .none {
//            setTargetContentOffset(endScrollTargetLocation)
//            return
//        }
        
        if directionVelocity == 0.0 {
            decelerationRate = UIScrollViewDecelerationRateFast
        }
        
//        if didEndScollCount > 0, directionVelocity == 0 {
            switch scrollingMode {
            case .nonStopToSection, .none:
                let x = stop(scrollView, with: scrollData)
                setTargetContentOffset(x)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.decelerationRate = UIScrollViewDecelerationRateNormal
                }
                return
            default:
                //                setTargetContentOffset(endScrollTargetLocation)
                break
                
            }
            
//        }
        
        didEndScollCount += 1
        
        
        
        
        let isScrollingForward = {
            return directionVelocity > 0 ||  contentOffset > self.scrollDraggBeginningPoint
        }
        
        let calculatedCurrentFixedContentOffsetFrom = {(interval: CGFloat) -> CGFloat in
            if isScrollingForward() {
                return ceil(contentOffset / interval) * interval
            } else {
                return floor(contentOffset / interval) * interval
            }
        }
        
        let recalculateOffset = {(diff: CGFloat, interval: CGFloat) -> CGFloat in
            if isScrollingForward() {
                let recalcOffsetAfterResistanceApplied = theTargetContentOffset - diff
                return ceil(recalcOffsetAfterResistanceApplied / interval) * interval
            } else {
                let recalcOffsetAfterResistanceApplied = theTargetContentOffset + diff
                return floor(recalcOffsetAfterResistanceApplied / interval) * interval
            }
        }
        
        let scrollViewShouldStopAtBeginning = {() -> Bool in
            return contentOffset < 0 && theTargetContentOffset == 0 ?
                true : false
        }
        let scrollViewShouldStopAtEnd = {
            (calculatedOffSet: CGFloat) -> Bool in
            return calculatedOffSet > contentSizeEndOffset
        }
        switch scrollingMode {
        case let .stopAtEach(customInterval: interval):
            let calculatedOffset = calculatedCurrentFixedContentOffsetFrom(interval)
            setTargetContentOffset(calculatedOffset)
        case .stopAtEachCalendarFrame:
            #if os(tvOS)
                let interval = scrollDirection == .horizontal ? scrollView.frame.width : scrollView.frame.height
                let calculatedOffset = calculatedCurrentFixedContentOffsetFrom(interval)
                setTargetContentOffset(calculatedOffset)
            #else
                setTargetContentOffset(scrollDirection == .horizontal ? targetContentOffset.pointee.x : targetContentOffset.pointee.y)
            #endif
            break
        case .stopAtEachSection:
            var calculatedOffSet: CGFloat = 0
            if scrollDirection == .horizontal ||
                (scrollDirection == .vertical && !calendarViewLayout.thereAreHeaders && cachedConfiguration.generateOutDates == .tillEndOfGrid) {
                // Horizontal has a fixed width.
                // Vertical with no header has fixed height
                let interval = calendarLayout.sizeOfContentForSection(theCurrentSection)
                calculatedOffSet = calculatedCurrentFixedContentOffsetFrom(interval)
            } else {
                // Vertical with headers have variable heights.
                // It needs to be calculated
                let currentScrollOffset = scrollView.contentOffset.y
                let currentScrollSection = calendarLayout.sectionFrom(currentScrollOffset)
                var sectionSize: CGFloat = 0
                if isScrollingForward() {
                    sectionSize = calendarLayout.sectionSize[currentScrollSection]
                    calculatedOffSet = sectionSize
                } else {
                    if currentScrollSection - 1  >= 0 {
                        calculatedOffSet = calendarLayout.sectionSize[currentScrollSection - 1]
                    }
                }
            }
            setTargetContentOffset(calculatedOffSet)
        case .nonStopToCell, .nonStopTo:
            let diff = abs(theTargetContentOffset - contentOffset)
            let targetSection = calendarLayout.sectionFrom(theTargetContentOffset)
            var calculatedOffSet = contentOffset
            switch scrollingMode {
            case let .nonStopToCell(resistance):
                let interval = calendarLayout.cellCache[targetSection]![0].4
                let diffResistance = diff * resistance
                if scrollDirection == .horizontal {
                    if scrollViewShouldStopAtBeginning() {
                        calculatedOffSet = 0
                    } else if scrollViewShouldStopAtEnd(calculatedOffSet) {
                        calculatedOffSet = theTargetContentOffset
                    } else {
                        calculatedOffSet = recalculateOffset(diffResistance, interval)
                    }
                } else {
                    var stopSection: Int
                    if isScrollingForward() {
                        calculatedOffSet = scrollViewShouldStopAtEnd(calculatedOffSet) ? theTargetContentOffset : theTargetContentOffset - diffResistance
                        stopSection = calendarLayout.sectionFrom(calculatedOffSet)
                    } else {
                        calculatedOffSet = scrollViewShouldStopAtBeginning() ? 0 : theTargetContentOffset + diffResistance
                        stopSection = calendarLayout.sectionFrom(calculatedOffSet)
                    }
                    let pathPoint = CGPoint( x: targetContentOffset.pointee.x, y: calculatedOffSet)
                    let attribPath = IndexPath(item: 0, section: stopSection)
                    if contentOffset > 0, let path = indexPathForItem(at: pathPoint) {
                        guard let attrib = calendarViewLayout.layoutAttributesForItem(at: path) else { return }
                        if isScrollingForward() {
                            calculatedOffSet = attrib.frame.origin.y + attrib.frame.size.height
                        } else {
                            calculatedOffSet = attrib.frame.origin.y
                        }
                    } else if calendarViewLayout.thereAreHeaders,
                        let attrib = calendarLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: attribPath) { // JT101 this was changed
                        // change the final value to the end of the header
                        if isScrollingForward() {
                            calculatedOffSet = attrib.frame.origin.y + attrib.frame.size.height
                        } else {
                            calculatedOffSet = stopSection - 1 < 0 ? 0 : calendarLayout.sectionSize[stopSection - 1]
                        }
                    }
                }
                setTargetContentOffset(calculatedOffSet)
            case let .nonStopTo(interval, resistance):
                // Both horizontal and vertical are fixed
                let diffResistance = diff * resistance
                calculatedOffSet =
                    recalculateOffset(diffResistance, interval)
                setTargetContentOffset(calculatedOffSet)
            default:
                break
            }
        case .none: break
        default: break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.decelerationRate = self.decelerationRateMatchingScrollingMode
        }
        
        DispatchQueue.main.async {
            self.calendarDelegate?.scrollDidEndDecelerating(for: self)
        }
    }
    
    func stop(_ scrollView: UIScrollView, with scrollData: ScrollData) -> CGFloat {
        return stopVertical(scrollView, with: scrollData)
    }
    func stopVertical(_ scrollView: UIScrollView, with scrollData: ScrollData) -> CGFloat {
        var retval: CGFloat = 0
        switch scrollingMode {
            
        case .stopAtEachCalendarFrame:
            break
        case .stopAtEachSection:
            break
        case .stopAtEach(let customInterval):
            break
        case .nonStopToSection(let resistance):
            var scrollData = scrollData
            scrollData.resistance = resistance
            retval = stopVerticalNonStopAtEachSection(scrollView, with: scrollData)
        case .nonStopToCell(let withResistance):
            break
        case .nonStopTo(let customInterval, let withResistance):
            break
        case .none(let resistance):
            var scrollData = scrollData
            scrollData.resistance = resistance
            retval = valueAfterResistance(scrollData: scrollData)
        }
        
        return retval
    }
    
    func valueAfterResistance(scrollData: ScrollData) -> CGFloat {
        let diff = abs(scrollData.theTargetContentOffset - scrollData.contentOffset)
        let diffResistance = diff * scrollData.resistance
        let retval: CGFloat
        if scrollData.isScrollingForward {
            retval = scrollData.theTargetContentOffset - diffResistance
        } else {
            retval = scrollData.theTargetContentOffset + diffResistance
        }
        
        return retval
    }
    
    func stopVerticalNonStopAtEachSection(_ scrollView: UIScrollView, with scrollData: ScrollData) -> CGFloat {
        var retval: CGFloat = 0
        let calendarLayout = calendarViewLayout
        let calculatedOffSet = valueAfterResistance(scrollData: scrollData)
        
        let currentSection = calendarLayout.sectionFrom(calculatedOffSet)
        let sizeOfCurrentSection = calendarLayout.sizeOfContentForSection(currentSection)
        let attrib: UICollectionViewLayoutAttributes = calendarLayout.thereAreHeaders ?
            calendarLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: currentSection))! :
            calendarLayout.layoutAttributesForItem(at: IndexPath(item: 0, section: currentSection))!
        
        let startOfsetForHeader = attrib.frame.origin.y
        let x = scrollData.contentOffset - startOfsetForHeader
        let y = sizeOfCurrentSection
        let percentage = (x / y) * 100.0
        let percentageRate: CGFloat = scrollData.isScrollingForward ? 4.0 : 96.0
        
        if percentage < percentageRate {
            retval = startOfsetForHeader
            
        } else {
            
            let attrib: UICollectionViewLayoutAttributes = calendarLayout.thereAreHeaders ?
                calendarLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: currentSection + 1))! :
                calendarLayout.layoutAttributesForItem(at: IndexPath(item: 0, section: currentSection + 1))!
            
            let startOfsetForHeader = attrib.frame.origin.y
            retval = startOfsetForHeader
        }
        return retval
    }
    
    /// Tells the delegate when a scrolling
    /// animation in the scroll view concludes.
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrollInProgress = false
        if
            let shouldTrigger = triggerScrollToDateDelegate,
            shouldTrigger == true {
            scrollViewDidEndDecelerating(scrollView)
            triggerScrollToDateDelegate = nil
        }
        executeDelayedTasks(.scroll)
    }
    
    /// Tells the delegate that the scroll view has
    /// ended decelerating the scrolling movement.
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndScollCount = 0
        visibleDates {[unowned self] dates in
            self.calendarDelegate?.calendar(self, didScrollToDateSegmentWith: dates)
        }
    }
    
    /// Tells the delegate that a scroll occured
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calendarDelegate?.calendarDidScroll(self)
    }
}
