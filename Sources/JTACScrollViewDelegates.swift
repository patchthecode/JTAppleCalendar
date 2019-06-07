//
//  JTACScrollViewDelegates.swift
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
extension JTACMonthView: UIScrollViewDelegate {
    /// Inform the scrollViewDidEndDecelerating
    /// function that scrolling just occurred
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(self)
    }

    /// Tells the delegate when the user finishes scrolling the content.
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let theCurrentSection = currentSection() else { return }
        
        let maxContentOffset: CGFloat
        var theCurrentContentOffset: CGFloat = 0,
        theTargetContentOffset: CGFloat = 0,
        directionVelocity: CGFloat = 0
        let calendarLayout = calendarViewLayout
        if scrollDirection == .horizontal {
            theCurrentContentOffset = scrollView.contentOffset.x
            theTargetContentOffset = targetContentOffset.pointee.x
            directionVelocity = velocity.x
            maxContentOffset = scrollView.contentSize.width - scrollView.frame.width
        } else {
            theCurrentContentOffset = scrollView.contentOffset.y
            theTargetContentOffset = targetContentOffset.pointee.y
            directionVelocity = velocity.y
            maxContentOffset = scrollView.contentSize.height - scrollView.frame.height
        }

        let gestureTranslation = self.panGestureRecognizer.translation(in: self)
        let translation = self.scrollDirection == .horizontal ? gestureTranslation.x : gestureTranslation.y
        
        
        
        let setTargetContentOffset = {(finalOffset: CGFloat) -> Void in
            if self.scrollDirection == .horizontal {
                targetContentOffset.pointee.x = finalOffset
            } else {
                targetContentOffset.pointee.y = finalOffset
            }
            self.endScrollTargetLocation = finalOffset
        }
        
        if directionVelocity == 0.0 {
            decelerationRate = .fast
        }

        if theCurrentContentOffset >= maxContentOffset { setTargetContentOffset(maxContentOffset) ; return }
        if theCurrentContentOffset <= 0 { setTargetContentOffset(0); return }

        switch scrollingMode {
        case .stopAtEachCalendarFrame:
            let interval = scrollDirection == .horizontal ? scrollView.frame.width : scrollView.frame.height
            let offset = scrollDecision(currentScrollDirectionValue: translation,
                                                    previousScrollDirectionValue: lastMovedScrollDirection,
                                                    forward: { () -> CGFloat in return ceil(theCurrentContentOffset / interval) * interval },
                                                    backward: { () -> CGFloat in return floor(theCurrentContentOffset / interval) * interval})
            setTargetContentOffset(offset)
            
        case let .stopAtEach(customInterval: interval): 
            let offset = scrollDecision(currentScrollDirectionValue: translation,
                                                    previousScrollDirectionValue: lastMovedScrollDirection,
                                                    forward: { return ceil(theCurrentContentOffset / interval) * interval },
                                                    backward: { return floor(theCurrentContentOffset / interval) * interval})
            setTargetContentOffset(offset)
        case .stopAtEachSection:
            let section = scrollDecision(currentScrollDirectionValue: translation,
                                                     previousScrollDirectionValue: lastMovedScrollDirection,
                                                     forward: { return theCurrentSection},
                                                     backward: { return theCurrentSection - 1},
                                                     fixed: { return theCurrentSection})

            guard section >= 0, section < calendarLayout.endOfSectionOffsets.count else {setTargetContentOffset(0); return}
            let endOfCurrentSectionOffset = calendarLayout.endOfSectionOffsets[theCurrentSection]
            let endOfPreviousSectionOffset = calendarLayout.endOfSectionOffsets[theCurrentSection - 1 < 0 ? 0 : theCurrentSection - 1]
            let midPoint = (endOfCurrentSectionOffset + endOfPreviousSectionOffset) / 2
            let maxSnap = calendarLayout.endOfSectionOffsets[section]
            
            let userPercentage: CGFloat = 20
            let modifiedPercentage = CGFloat((100 - userPercentage) / 100.0)
            
            let snapForward = midPoint - ((maxSnap - midPoint) * modifiedPercentage)
            
            scrollDecision(currentScrollDirectionValue: translation,
                           previousScrollDirectionValue: lastMovedScrollDirection,
                           forward: {
                                if theCurrentContentOffset >= snapForward || directionVelocity > 0 {
                                    setTargetContentOffset(endOfCurrentSectionOffset)
                                } else {
                                    setTargetContentOffset(endOfPreviousSectionOffset)
                                }
                           },
                           backward: {
                                if theCurrentContentOffset <= snapForward || directionVelocity < 0 {
                                    setTargetContentOffset(endOfPreviousSectionOffset)
                                } else {
                                    setTargetContentOffset(endOfCurrentSectionOffset)
                                }
                           })
        case let .nonStopToCell(withResistance: resistance), let .nonStopToSection(withResistance: resistance):
            
            let (recalculatedOffset, elementProperties) = rectAfterApplying(resistance: resistance,
                                                                            targetContentOffset: theTargetContentOffset,
                                                                            currentContentOffset: theCurrentContentOffset,
                                                                            currentScrollDirectionValue: translation,
                                                                            previousScrollDirectionValue: lastMovedScrollDirection)
            
            guard let validElementProperties = elementProperties else { setTargetContentOffset(recalculatedOffset); return }

            switch scrollingMode {
            case .nonStopToCell:
                let midPoint = scrollDirection == .horizontal ? (validElementProperties.xOffset + (validElementProperties.xOffset + validElementProperties.width)) / 2 : (validElementProperties.yOffset + ( validElementProperties.yOffset + validElementProperties.height)) / 2
                let calculatedOffSet: CGFloat
                if recalculatedOffset > midPoint || theTargetContentOffset >= maxContentOffset {
                    calculatedOffSet = self.scrollDirection == .horizontal ? validElementProperties.xOffset + validElementProperties.width : validElementProperties.yOffset + validElementProperties.height
                } else {
                    calculatedOffSet = self.scrollDirection == .horizontal ? validElementProperties.xOffset : validElementProperties.yOffset
                }
                setTargetContentOffset(calculatedOffSet)
            case .nonStopToSection:
                let stopSection = scrollDecision(currentScrollDirectionValue: translation,
                                                             previousScrollDirectionValue: lastMovedScrollDirection,
                                                             forward: { validElementProperties.section },
                                                             backward: {validElementProperties.section - 1})
 
                let calculatedOffSet = (stopSection < 0 || stopSection > calendarLayout.endOfSectionOffsets.count - 1) ? 0 : calendarLayout.endOfSectionOffsets[stopSection]
                setTargetContentOffset(calculatedOffSet)
            default: return
            }
            
        case let .nonStopTo(interval, resistance):
            let diffResist = diffResistance(targetOffset: theTargetContentOffset, currentOffset: theCurrentContentOffset, resistance: resistance)
            let recalculatedOffsetAfterResistance = scrollDecision(currentScrollDirectionValue: translation,
                                                                   previousScrollDirectionValue: lastMovedScrollDirection,
                                                                   forward: { theTargetContentOffset - diffResist },
                                                                   backward: { theTargetContentOffset + diffResist })

            let offset = scrollDecision(currentScrollDirectionValue: translation,
                                        previousScrollDirectionValue: lastMovedScrollDirection,
                                        forward: { ceil(recalculatedOffsetAfterResistance / interval) * interval },
                                        backward: { floor(recalculatedOffsetAfterResistance / interval) * interval })
            
            setTargetContentOffset(offset)
        case .none: break
        }
        
        let futureScrollPoint = CGPoint(x: targetContentOffset.pointee.x, y: targetContentOffset.pointee.y)
        let dateSegmentInfo = datesAtCurrentOffset(futureScrollPoint)
        calendarDelegate?.calendar(self, willScrollToDateSegmentWith: dateSegmentInfo)

        self.lastMovedScrollDirection = translation
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.decelerationRate = UIScrollView.DecelerationRate(rawValue: self.decelerationRateMatchingScrollingMode)
        }
        
        DispatchQueue.main.async {
            self.calendarDelegate?.scrollDidEndDecelerating(for: self)
        }
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
        
        DispatchQueue.main.async { // https://github.com/patchthecode/JTAppleCalendar/issues/778
            self.executeDelayedTasks(.scroll)
        }
    }
    
    /// Tells the delegate that the scroll view has
    /// ended decelerating the scrolling movement.
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        visibleDates {[unowned self] dates in
            self.calendarDelegate?.calendar(self, didScrollToDateSegmentWith: dates)
        }
    }
    
    /// Tells the delegate that a scroll occured
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calendarDelegate?.calendarDidScroll(self)
    }
    
    func rectAfterApplying(resistance: CGFloat,
                           targetContentOffset: CGFloat,
                           currentContentOffset: CGFloat,
                           currentScrollDirectionValue: CGFloat,
                           previousScrollDirectionValue: CGFloat) -> (recalculatedOffset: CGFloat, elementProperty: (item: Int, section: Int, xOffset: CGFloat, yOffset: CGFloat, width: CGFloat, height: CGFloat)?) {
        
        let diffResist = diffResistance(targetOffset: targetContentOffset, currentOffset: currentContentOffset, resistance: resistance)
        let recalcOffsetAfterResistanceApplied = scrollDecision(currentScrollDirectionValue: currentScrollDirectionValue,
                                                                previousScrollDirectionValue: previousScrollDirectionValue,
                                                                forward: { () -> CGFloat in return targetContentOffset - diffResist },
                                                                backward: { () -> CGFloat in return targetContentOffset + diffResist })
 
        let element: UICollectionViewLayoutAttributes?
        let rect: CGRect
        if scrollDirection == .horizontal {
            rect = CGRect(x: recalcOffsetAfterResistanceApplied + 1, y: contentOffset.y + 1, width: 10, height: frame.height - 2)
            element = calendarViewLayout.elementsAtRect(excludeHeaders: true, from: rect).sorted { $0.indexPath < $1.indexPath }.first
        } else {
            rect = CGRect(x: contentOffset.x + 1, y: recalcOffsetAfterResistanceApplied + 1, width: frame.width - 2, height: 10)
            element = calendarViewLayout.elementsAtRect(from: rect).sorted { $0.indexPath < $1.indexPath }.first
        }
        
        guard let validElement = element else { return (recalcOffsetAfterResistanceApplied, nil) }
        let elementProperties:  (item: Int, section: Int, xOffset: CGFloat, yOffset: CGFloat, width: CGFloat, height: CGFloat)?
        
        if validElement.representedElementKind == UICollectionView.elementKindSectionHeader {
            elementProperties = calendarViewLayout.headerCache[validElement.indexPath.section]
        } else {
            elementProperties = calendarViewLayout.cachedValue(for: validElement.indexPath.item, section: validElement.indexPath.section)
        }
        
        return (recalcOffsetAfterResistanceApplied, elementProperties)
    }
    
    func diffResistance(targetOffset: CGFloat, currentOffset: CGFloat, resistance: CGFloat) -> CGFloat {
        let difference = abs(targetOffset - currentOffset)
        return difference * resistance
    }
    
    func scrollDecision<T>(currentScrollDirectionValue: CGFloat,
                           previousScrollDirectionValue: CGFloat,
                           forward: ()->T,
                           backward: ()->T,
                           fixed: (()->T)? = nil) -> T {
        if currentScrollDirectionValue < 0 {
            return forward()
        } else if currentScrollDirectionValue > 0 {
            return backward()
        } else if previousScrollDirectionValue < 0 {
            return forward()
        } else if previousScrollDirectionValue > 0 {
            return backward()
        } else {
            guard let fixed = fixed else { return forward() }
            return fixed()
        }
    }
}
