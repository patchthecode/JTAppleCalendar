//
//  JTACMonthLayoutVerticalCalendar.swift
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

extension JTACMonthLayout {
    
    func configureVerticalLayout() {
        var virtualSection = 0
        var totalDayCounter = 0
        let fullSection = numberOfRows * maxNumberOfDaysInWeek
        
        xCellOffset   = sectionInset.left
        yCellOffset   = sectionInset.top
        contentHeight = sectionInset.top
        endSeparator  = sectionInset.top + sectionInset.bottom
        
        for aMonth in monthInfo {
            for numberOfDaysInCurrentSection in aMonth.sections {
                // Generate and cache the headers
                if let aHeaderAttr = determineToApplySupplementaryAttribs(0, section: virtualSection) {
                    headerCache[virtualSection] = aHeaderAttr
                    if strictBoundaryRulesShouldApply {
                        contentHeight += aHeaderAttr.height
                        yCellOffset += aHeaderAttr.height
                    }
                }
                // Generate and cache the cells
                for dayCounter in 1...numberOfDaysInCurrentSection {
                    totalDayCounter += 1
                    guard let attribute = determineToApplyAttribs(dayCounter - 1, section: virtualSection) else { continue }
                    if cellCache[virtualSection] == nil { cellCache[virtualSection] = [] }
                    cellCache[virtualSection]!.append(attribute)
                    lastWrittenCellAttribute = attribute
                    xCellOffset += attribute.width
                    
                    if strictBoundaryRulesShouldApply {
                        if dayCounter == numberOfDaysInCurrentSection || dayCounter % maxNumberOfDaysInWeek == 0 {
                            // We are at the last item in the
                            // section && if we have headers
                            
                            xCellOffset = sectionInset.left
                            yCellOffset += attribute.height
                            contentHeight += attribute.height
                            
                            if dayCounter == numberOfDaysInCurrentSection {
                                yCellOffset   += sectionInset.top
                                contentHeight += sectionInset.top
                                endOfSectionOffsets.append(contentHeight - sectionInset.top)
                            }
                        }
                    } else {
                        if totalDayCounter % fullSection == 0 {
                            
                            yCellOffset += attribute.height + sectionInset.top
                            xCellOffset = sectionInset.left
                            contentHeight = yCellOffset
                            endOfSectionOffsets.append(contentHeight - sectionInset.top)
                            
                        } else {
                            if totalDayCounter >= delegate.totalDays {
                                yCellOffset += attribute.height + sectionInset.top
                                contentHeight = yCellOffset
                                endOfSectionOffsets.append(contentHeight - sectionInset.top)
                            }
                            
                            if totalDayCounter % maxNumberOfDaysInWeek == 0 {
                                xCellOffset = sectionInset.left
                                yCellOffset += attribute.height
                            }
                        }
                    }
                }
                virtualSection += 1
            }
        }
        contentWidth = self.collectionView!.bounds.size.width
    }
}
