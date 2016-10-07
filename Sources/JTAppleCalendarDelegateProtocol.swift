//
//  JTAppleCalendarDelegateProtocol.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-09-19.
//
//


protocol JTAppleCalendarDelegateProtocol: class {
    var itemSize: CGFloat? {get set}
    var registeredHeaderViews: [JTAppleCalendarViewSource] {get set}
    var cachedConfiguration: ConfigurationParameters {get set}
    var monthInfo: [Month] {get set}
    var monthMap: [Int: Int] {get set}
    var totalDays: Int {get}
    func numberOfRows() -> Int
    func cachedDate() -> (start: Date, end: Date, calendar: Calendar)
    func numberOfMonthsInCalendar() -> Int
    func numberOfPreDatesForMonth(_ month: Date) -> Int

    func referenceSizeForHeaderInSection(_ section: Int) -> CGSize
    func firstDayIndexForMonth(_ date: Date) -> Int
    func rowsAreStatic() -> Bool
    func preDatesAreGenerated() -> Bool
    func postDatesAreGenerated() -> OutDateCellGeneration
}

extension JTAppleCalendarView: JTAppleCalendarDelegateProtocol {

    func cachedDate() -> (start: Date, end: Date, calendar: Calendar) {
        return (start: cachedConfiguration.startDate,
                end: cachedConfiguration.endDate,
                calendar: cachedConfiguration.calendar)
    }

    func numberOfRows() -> Int {
        return cachedConfiguration.numberOfRows
    }

    func numberOfMonthsInCalendar() -> Int {
        return numberOfMonths
    }

    func numberOfPreDatesForMonth(_ month: Date) -> Int {
        return firstDayIndexForMonth(month)
    }

    func preDatesAreGenerated() -> Bool {
        return cachedConfiguration.generateInDates
    }

    func postDatesAreGenerated() -> OutDateCellGeneration {
        return cachedConfiguration.generateOutDates
    }

    func referenceSizeForHeaderInSection(_ section: Int) -> CGSize {
        return calendarViewHeaderSizeForSection(section)
    }

    func rowsAreStatic() -> Bool {
        return cachedConfiguration.generateInDates == true &&
            cachedConfiguration.generateOutDates == .tillEndOfGrid
    }

}
