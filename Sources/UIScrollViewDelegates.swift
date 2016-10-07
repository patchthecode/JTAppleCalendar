//
//  JTAppleCalendarDelegates.swift
//  Pods
//
//  Created by JayT on 2016-05-12.
//
//

extension JTAppleCalendarView: UIScrollViewDelegate {

    /// Inform the scrollViewDidEndDecelerating
    /// function that scrolling just occurred
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.scrollViewDidEndDecelerating(calendarView)
    }

    /// Tells the delegate when the user finishes scrolling the content.
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let saveLastContentOffset = {
                self.lastSavedContentOffset = self.direction == .horizontal ?
                    targetContentOffset.pointee.x :
                    targetContentOffset.pointee.y
            }
            let cachedDecelerationRate = calendarView.decelerationRate
            let theCurrentSection = currentSectionPage
            let contentSizeEndOffset: CGFloat
            var contentOffset: CGFloat = 0,
            theTargetContentOffset: CGFloat = 0,
            directionVelocity: CGFloat = 0
            let calendarLayout = self.calendarViewLayout
            if direction == .horizontal {
                contentOffset = scrollView.contentOffset.x
                theTargetContentOffset = targetContentOffset.pointee.x
                directionVelocity = velocity.x
                contentSizeEndOffset =
                    scrollView.contentSize.width - scrollView.frame.width
            } else {
                contentOffset = scrollView.contentOffset.y
                theTargetContentOffset = targetContentOffset.pointee.y
                directionVelocity = velocity.y
                contentSizeEndOffset =
                    scrollView.contentSize.height - scrollView.frame.height
            }
            let isScrollingForward = {
                return directionVelocity > 0 ||
                    contentOffset > self.lastSavedContentOffset
            }
            let isNotScrolling = {
                return contentOffset == self.lastSavedContentOffset
            }
            if isNotScrolling() {
                return
            }
            if directionVelocity == 0.0 {
                calendarView.decelerationRate =
                    UIScrollViewDecelerationRateFast
            }

            let setTargetContentOffset = {
                (finalOffset: CGFloat) -> Void in
                if self.direction == .horizontal {
                    targetContentOffset.pointee.x = finalOffset
                } else {
                    targetContentOffset.pointee.y = finalOffset
                }
            }

            let calculatedCurrentFixedContentOffsetFrom = {
                (interval: CGFloat) -> CGFloat in
                if isScrollingForward() {
                    return ceil(contentOffset / interval) * interval
                } else {
                    return floor(contentOffset / interval) * interval
                }
            }

            let recalculateOffset = {
                (diff: CGFloat, interval: CGFloat) -> CGFloat in
                if isScrollingForward() {
                    let recalcOffsetAfterResistanceApplied =
                        theTargetContentOffset - diff
                    return ceil(recalcOffsetAfterResistanceApplied /
                        interval) * interval
                } else {
                    let recalcOffsetAfterResistanceApplied =
                        theTargetContentOffset + diff
                    return floor(recalcOffsetAfterResistanceApplied /
                        interval) * interval
                }
            }

            let scrollViewShouldStopAtBeginning = {
                () -> Bool in
                return contentOffset < 0 && theTargetContentOffset == 0 ?
                    true : false
            }
            let scrollViewShouldStopAtEnd = {
                (calculatedOffSet: CGFloat) -> Bool in
                return calculatedOffSet > contentSizeEndOffset
            }
            switch scrollingMode {
            case let .stopAtEach(customInterval: interval):
                let calculatedOffset =
                    calculatedCurrentFixedContentOffsetFrom(interval)
                setTargetContentOffset(calculatedOffset)
            case .stopAtEachCalendarFrameWidth:
                #if os(tvOS)
                    let interval = self.direction == .horizontal ?
                        scrollView.frame.width : scrollView.frame.height
                    let calculatedOffset =
                        calculatedCurrentFixedContentOffsetFrom(interval)
                    setTargetContentOffset(calculatedOffset)
                #endif
                break
            case .stopAtEachSection:
                var calculatedOffSet: CGFloat = 0
                if self.direction == .horizontal ||
                    (self.direction == .vertical &&
                        self.registeredHeaderViews.count < 1) {
                            // Horizontal has a fixed width.
                            // Vertical with no header has fixed height
                            let interval = calendarLayout
                                .sizeOfContentForSection(theCurrentSection)
                            calculatedOffSet =
                                calculatedCurrentFixedContentOffsetFrom(
                                    interval)
                } else {
                    // Vertical with headers have variable heights.
                    // It needs to be calculated
                    let currentScrollOffset = scrollView.contentOffset.y
                    let currentScrollSection =
                        calendarLayout.sectionFromOffset(currentScrollOffset)
                    var sectionSize: CGFloat = 0
                    if isScrollingForward() {
                        sectionSize = calendarLayout
                            .sectionSize[currentScrollSection]
                        calculatedOffSet = sectionSize
                    } else {
                        if currentScrollSection - 1  >= 0 {
                            calculatedOffSet = calendarLayout
                                .sectionSize[currentScrollSection - 1]
                        }
                    }
                }
                setTargetContentOffset(calculatedOffSet)
            case .nonStopToSection, .nonStopToCell, .nonStopTo:
                let diff = abs(theTargetContentOffset - contentOffset)
                let targetSection = calendarLayout
                    .sectionFromOffset(theTargetContentOffset)
                var calculatedOffSet = contentOffset
                switch scrollingMode {
                case let .nonStopToSection(resistance):
                    let interval = calendarLayout
                        .sizeOfContentForSection(targetSection)
                    let diffResistance = diff * resistance
                    if direction == .horizontal {
                        calculatedOffSet =
                            recalculateOffset(diffResistance, interval)
                    } else {
                        if isScrollingForward() {
                            calculatedOffSet =
                                theTargetContentOffset - diffResistance
                        } else {
                            calculatedOffSet =
                                theTargetContentOffset + diffResistance
                        }
                        let stopSection = isScrollingForward() ?
                            calendarLayout
                                .sectionFromOffset(calculatedOffSet) :
                            calendarLayout
                                .sectionFromOffset(calculatedOffSet) - 1
                        calculatedOffSet = stopSection < 0 ?
                            0 : calendarLayout.sectionSize[stopSection]
                    }
                    setTargetContentOffset(calculatedOffSet)
                case let .nonStopToCell(resistance):
                    let interval = calendarLayout
                        .cellCache[targetSection]![0].frame.width
                    let diffResistance = diff * resistance
                    if direction == .horizontal {
                        if scrollViewShouldStopAtBeginning() {
                            calculatedOffSet = 0
                        } else if
                            scrollViewShouldStopAtEnd(calculatedOffSet) {
                                calculatedOffSet = theTargetContentOffset
                        } else {
                            calculatedOffSet =
                                recalculateOffset(diffResistance, interval)
                        }
                    } else {
                        var stopSection: Int
                        if isScrollingForward() {
                            calculatedOffSet =
                                scrollViewShouldStopAtEnd(calculatedOffSet) ?
                                    theTargetContentOffset :
                                    theTargetContentOffset - diffResistance
                            stopSection = calendarLayout
                                .sectionFromOffset(calculatedOffSet)
                        } else {
                            calculatedOffSet =
                                scrollViewShouldStopAtBeginning() ?
                                    0 :
                                    theTargetContentOffset + diffResistance
                            stopSection = calendarLayout
                                .sectionFromOffset(calculatedOffSet)
                        }
                        let pathPoint = CGPoint(
                            x: targetContentOffset.pointee.x,
                            y: calculatedOffSet
                        )
                        let attribPath =
                            IndexPath(item: 0, section: stopSection)
                        if contentOffset > 0, let path = self
                            .calendarView.indexPathForItem(at: pathPoint) {
                                let attrib = self.calendarView
                                    .layoutAttributesForItem(at: path)!
                                if isScrollingForward() {
                                    calculatedOffSet =
                                        attrib.frame.origin.y +
                                        attrib.frame.size.height
                                } else {
                                    calculatedOffSet = attrib.frame.origin.y
                                }
                        } else if registeredHeaderViews.count > 0,
                            let attrib = self.calendarView
                                .layoutAttributesForSupplementaryElement(
                                    ofKind:
                                        UICollectionElementKindSectionHeader,
                                    at: attribPath) {

                            // change the final value to the end of the header
                            if isScrollingForward() {
                                calculatedOffSet =
                                    attrib.frame.origin.y +
                                    attrib.frame.size.height
                            } else {
                                calculatedOffSet =
                                    stopSection - 1 < 0 ?
                                    0 :
                                    calendarLayout
                                        .sectionSize[stopSection - 1]
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
            default:
                // If we go through this route, then no animated scrolling
                // was done. User scrolled and stopped and lifted finger.
                // Thus update the label.
                delayRunOnMainThread(0.0) {
                    self.scrollViewDidEndDecelerating(self.calendarView)
                }
            }
            saveLastContentOffset()
            delayRunOnMainThread(0.7) {
                self.calendarView.decelerationRate = cachedDecelerationRate
            }
    }

    /// Tells the delegate when a scrolling
    /// animation in the scroll view concludes.
    public func scrollViewDidEndScrollingAnimation(
        _ scrollView: UIScrollView) {
            if
                let shouldTrigger = triggerScrollToDateDelegate,
                shouldTrigger == true {
                scrollViewDidEndDecelerating(scrollView)
                triggerScrollToDateDelegate = nil
            }
            executeDelayedTasks()
            // A scroll was just completed.
            scrollInProgress = false
    }

    /// Tells the delegate that the scroll view has
    /// ended decelerating the scrolling movement.
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentSegmentDates = dateSegment()
        self.delegate?.calendar(
            self,
            didScrollToDateSegmentFor: (
                start: currentSegmentDates.range.start,
                end: currentSegmentDates.range.end
            ),
            belongingTo: currentSegmentDates.month,
            rows: currentSegmentDates.rowsForSection
        )
    }

}
