//
//  CalendarPicker+JTMonthView.swift
//  SampleJTAppleCalendar
//
//  Created by Paul Addy on 29/3/23.
//  Copyright © 2023 OsTech. All rights reserved.
//

import Foundation
import JTAppleCalendar
import UIKit

// MARK: - JTACMonthViewDataSource
extension CalendarPicker: JTACMonthViewDataSource {
    public func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        return calendarConfiguration
    }
}

// MARK: - JTACMonthViewDelegate
extension CalendarPicker: JTACMonthViewDelegate {
    public func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // This function should have the same code as the cellForItemAt function
        // ref: https://github.com/patchthecode/JTAppleCalendar/issues/553
        guard let dayCellView = cell as? CalendarDayCellView else {
            assertionFailure("missingData")
            return
        }
        dayCellView.configureForDisplay(
            text: cellState.text,
            isEnabled: isDateEnabled(date: cellState.date),
            isHidden: cellState.dateBelongsTo != .thisMonth,
            isSelected: isDateSelected(date: cellState.date),
            isToday: cellState.date.isToday(),
            inRangeStatus: inRangeStatus(date: cellState.date)
        )
    }

    public func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        guard let dayCellView = calendar.dequeueReusableCell(
            withReuseIdentifier: dayCellID,
            for: indexPath) as? CalendarDayCellView else {
            assertionFailure("missingData")
            return JTACDayCell()
        }
        dayCellView.configureForDisplay(
            text: cellState.text,
            isEnabled: isDateEnabled(date: cellState.date),
            isHidden: cellState.dateBelongsTo != .thisMonth,
            isSelected: isDateSelected(date: cellState.date),
            isToday: cellState.date.isToday(),
            inRangeStatus: inRangeStatus(date: cellState.date)
        )

        return dayCellView
    }

    public func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        return isDateEnabled(date: date)
    }

    public func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        didSelectOrDeselectDate(date)
    }

    public func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        didSelectOrDeselectDate(date)
    }

    // Sometimes either of `didSelectDate` or `didDeselectDate` is called unexpectedly,
    // so deal in one unified function to avoid complexity.
    // To check detailed requirements for `selectStartAndEnd`,
    // see https://redairship.atlassian.net/browse/FADEV-2861 and
    // https://redairship.atlassian.net/browse/FADEV-2861?focusedCommentId=36754
    private func didSelectOrDeselectDate(_ date: Date) {
        if isSelectDateRangeEnabled {
            if selectedDates.count == 1 && date > selectedDates[0] {
                selectedDates.append(date)
                return
            }
        } else if isDeselectingDateAllowed, let selectedDate = selectedDates[safe: 0],
                  date.isSameDay(as: selectedDate) {
            selectedDates = []
            return
        }
        selectedDates = [date]
    }

    public func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let first = visibleDates.monthDates.first else {
            return
        }
//        configureMonthView(date: first.date)
    }

    public func sizeOfDecorationView(indexPath: IndexPath) -> CGRect {
        let stride = calendar.frame.width * CGFloat(indexPath.section)
        return CGRect(x: stride + 5, y: 5, width: calendar.frame.width - 10, height: calendar.frame.height - 10)
    }
}
