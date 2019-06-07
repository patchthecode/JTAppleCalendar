//
//  JTACMonthLayoutHorizontalCalendar.swift
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
    func configureHorizontalLayout() {
        var virtualSection = 0
        var totalDayCounter = 0
        let fullSection = numberOfRows * maxNumberOfDaysInWeek
        
        xCellOffset = sectionInset.left
        endSeparator = sectionInset.left + sectionInset.right
        
        for aMonth in monthInfo {
            for numberOfDaysInCurrentSection in aMonth.sections {
                // Generate and cache the headers
                if let aHeaderAttr = determineToApplySupplementaryAttribs(0, section: virtualSection) {
                    headerCache[virtualSection] = aHeaderAttr
                    if strictBoundaryRulesShouldApply {
                        contentWidth += aHeaderAttr.width
                        yCellOffset = aHeaderAttr.height
                    }
                }
                // Generate and cache the cells
                for dayCounter in 1...numberOfDaysInCurrentSection {
                    guard let attribute = determineToApplyAttribs(dayCounter - 1, section: virtualSection)  else { continue }
                    if cellCache[virtualSection] == nil { cellCache[virtualSection] = [] }
                    cellCache[virtualSection]!.append(attribute)
                    lastWrittenCellAttribute = attribute
                    xCellOffset += attribute.width
                    
                    if strictBoundaryRulesShouldApply {
                        if dayCounter == numberOfDaysInCurrentSection || dayCounter % maxNumberOfDaysInWeek == 0 {
                            // We are at the last item in the section
                            // && if we have headers
                            xCellOffset = sectionInset.left
                            yCellOffset += attribute.height
                        }
                    } else {
                        totalDayCounter += 1
                        if totalDayCounter % fullSection == 0 {
                            yCellOffset = 0
                            xCellOffset = sectionInset.left
                            contentWidth += (attribute.width * 7) + endSeparator
                            xStride = contentWidth
                            endOfSectionOffsets.append(contentWidth)
                        } else {
                            if totalDayCounter >= delegate.totalDays {
                                contentWidth += (attribute.width * 7) + endSeparator
                                endOfSectionOffsets.append(contentWidth)
                            }
                            if totalDayCounter % maxNumberOfDaysInWeek == 0 {
                                xCellOffset = sectionInset.left
                                yCellOffset += attribute.height
                            }
                        }
                    }
                }
                
                // Save the content size for each section
                if strictBoundaryRulesShouldApply {
                    contentWidth += endSeparator
                    endOfSectionOffsets.append(contentWidth)
                    xStride = endOfSectionOffsets[virtualSection]
                }
                virtualSection += 1
            }
        }
        contentHeight = self.collectionView!.bounds.size.height
    }
}
