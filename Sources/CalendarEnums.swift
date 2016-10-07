//
//  CalendarEnums.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-08-22.
//
//

/// Describes the types of out-date cells to be generated.
public enum OutDateCellGeneration {
    /// tillEndOfRow will generate dates till it reaches the end of a row.
    /// endOfGrid will continue generating until it has filled a 6x7 grid.
    /// Off-mode will generate no postdates
    case tillEndOfRow, tillEndOfGrid, off
}

/// Describes which month owns the date
public enum DateOwner: Int {
    /// Describes which month owns the date
    case thisMonth = 0,
        previousMonthWithinBoundary,
        previousMonthOutsideBoundary,
        followingMonthWithinBoundary,
        followingMonthOutsideBoundary
}

/// Selection position of a range-selected date cell
public enum SelectionRangePosition: Int {
    /// Selection position
    case left = 1, middle, right, full, none
}

/// Days of the week. By setting you calandar's first day of week,
/// you can change which day is the first for the week. Sunday is by default.
public enum DaysOfWeek: Int {
    /// Days of the week.
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

enum JTAppleCalendarViewSource {
    case fromXib(String, Bundle?)
    case fromType(AnyClass)
    case fromClassName(String, Bundle?)
}
