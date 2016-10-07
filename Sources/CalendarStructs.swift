//
//  CalendarStructs.swift
//  JTAppleCalendar
//
//  Created by JayT on 2016-10-02.
//
//


/// Describes which month the cell belongs to
/// - ThisMonth: Cell belongs to the current month
/// - PreviousMonthWithinBoundary: Cell belongs to the previous month.
/// Previous month is included in the date boundary you have set in your
/// delegate - PreviousMonthOutsideBoundary: Cell belongs to the previous
/// month. Previous month is not included in the date boundary you have set
/// in your delegate - FollowingMonthWithinBoundary: Cell belongs to the
/// following month. Following month is included in the date boundary you have
/// set in your delegate - FollowingMonthOutsideBoundary: Cell belongs to the
/// following month. Following month is not included in the date boundary you
/// have set in your delegate You can use these cell states to configure how
/// you want your date cells to look. Eg. you can have the colors belonging
/// to the month be in color black, while the colors of previous months be in
/// color gray.
public struct CellState {
    /// returns true if a cell is selected
    public let isSelected: Bool
    /// returns the date as a string
    public let text: String
    /// returns the a description of which month owns the date
    public let dateBelongsTo: DateOwner
    /// returns the date
    public let date: Date
    /// returns the day
    public let day: DaysOfWeek
    /// returns the row in which the date cell appears visually
    public let row: () -> Int
    /// returns the column in which the date cell appears visually
    public let column: () -> Int
    /// returns the section the date cell belongs to
    public let dateSection: () ->
        (range: (start: Date, end: Date), month: Int, rowsForSection: Int)
    /// returns the position of a selection
    /// in the event you wish to do range selection
    public let selectedPosition: () -> SelectionRangePosition
    /// returns the cell frame.
    /// Useful if you wish to display something at the cell's frame/position
    public var cell: () -> JTAppleDayCell?
}

/// Defines the parameters which configures the calendar. The following
/// parameters are: - startDate: The start date boundary of your calendar -
/// endDate: The end-date boundary of your calendar - numberOfRows: Number of
/// rows you want to calendar to display per date section - calendar: Your
/// Calendar() instance. You are responsible for PROPERLY configuring this to
/// you region settings. All calendar calculations will be based on what you
/// have setup here. - generateInDates: Set to true if you want pre-dates to
/// be generated. - generateOutDates: Describes the types of out-date cells to
/// be generated. - firstDayOfWeek: Sets the first day of week.
public struct ConfigurationParameters {
    var startDate: Date
    var endDate: Date
    var numberOfRows: Int
    var calendar: Calendar
    var generateInDates: Bool
    var generateOutDates: OutDateCellGeneration
    var firstDayOfWeek: DaysOfWeek
    public init(startDate: Date,
                endDate: Date,
                numberOfRows: Int, calendar: Calendar,
                generateInDates: Bool,
                generateOutDates: OutDateCellGeneration,
                firstDayOfWeek: DaysOfWeek) {
        self.startDate = startDate
        self.endDate = endDate
        self.numberOfRows = numberOfRows
        self.calendar = calendar
        self.generateInDates = generateInDates
        self.generateOutDates = generateOutDates
        self.firstDayOfWeek = firstDayOfWeek
    }
}

struct CalendarData {
    var months: [Month]
    var totalSections: Int
    var monthMap: [Int: Int]
    var totalDays: Int
}

struct Month {

    // Start index day for the month.
    // The start is total number of days of previous months
    let startDayIndex: Int

    // Start cell index for the month.
    // The start is total number of cells of previous months
    let startCellIndex: Int

    // The total number of items in this array are the total number
    // of sections. The actual number is the number of items in each section
    let sections: [Int]

    let preDates: Int

    let postDates: Int

    // Maps a section to the index in the total number of sections
    let sectionIndexMaps: [Int: Int]

    // Number of rows for the month
    let rows: Int

    // Return the total number of days for the represented month
    var numberOfDaysInMonth: Int {
        get {
            return numberOfDaysInMonthGrid - preDates - postDates
        }
    }

    // Return the total number of day cells
    // to generate for the represented month
    var numberOfDaysInMonthGrid: Int {
        get {
            return sections.reduce(0, +)
        }
    }

    var startSection: Int {
        return sectionIndexMaps.keys.min()!
    }

    // Return the section in which a day is contained
    func indexPath(forDay number: Int) -> IndexPath? {
        var variableNumber = number
        let possibleSection = sections.index {
            let retval = variableNumber + preDates <= $0
            variableNumber -= $0
            return retval
            }!
        let theSection = sectionIndexMaps.key(for: possibleSection)!

        let dateOfStartIndex =
            sections[0..<possibleSection].reduce(0, +) - preDates + 1
        let itemIndex = number - dateOfStartIndex

        return IndexPath(item: itemIndex, section: theSection)
    }

    // Return the number of rows for a section in the month
    func numberOfRows(for section: Int, developerSetRows: Int) -> Int {
        var retval: Int
        guard let  theSection = sectionIndexMaps[section] else {
            return 0
        }
        let fullRows = rows / developerSetRows
        let partial = sections.count - fullRows

        if theSection + 1 <= fullRows {
            retval = developerSetRows
        } else if fullRows == 0 && partial > 0 {
            retval = rows
        } else {
            retval = 1
        }
        return retval
    }

    // Returns the maximum number of a rows for a completely full section
    func maxNumberOfRowsForFull(developerSetRows: Int) -> Int {
        var retval: Int
        let fullRows = rows / developerSetRows
        if fullRows < 1 {
            retval = rows
        } else {
            retval = developerSetRows
        }
        return retval
    }

}

struct DateConfigParameters {
    var inCellGeneration = true
    var outCellGeneration: OutDateCellGeneration = .tillEndOfGrid
    var numberOfRows = 6
    var startOfMonthCache: Date?
    var endOfMonthCache: Date?
    var configuredCalendar: Calendar?
    var firstDayOfWeek: DaysOfWeek = .sunday
}

struct JTAppleDateConfigGenerator {

    var parameters: DateConfigParameters?
    weak var delegate: JTAppleCalendarDelegateProtocol!

    mutating func setupMonthInfoDataForStartAndEndDate(
        _ parameters: DateConfigParameters?) -> (months: [Month],
        monthMap: [Int: Int], totalSections: Int, totalDays: Int) {
            self.parameters = parameters
            guard
                var validParameters = parameters,
                let  startMonth = validParameters.startOfMonthCache,
                let endMonth = validParameters.endOfMonthCache,
                let calendar = validParameters.configuredCalendar else {
                    return ([], [:], 0, 0)
            }
            // Only allow a row count of 1, 2, 3, or 6
            switch validParameters.numberOfRows {
            case 1, 2, 3:
                break
            default:
                validParameters.numberOfRows = 6
            }
            let differenceComponents = calendar.dateComponents(
                [.month], from: startMonth, to: endMonth)
            let numberOfMonths = differenceComponents.month! + 1
            // if we are for example on the same month
            // and the difference is 0 we still need 1 to display it
            var monthArray: [Month] = []
            var monthIndexMap: [Int: Int] = [:]
            var section = 0
            var startIndexForMonth = 0
            var startCellIndexForMonth = 0
            var totalDays = 0
            let numberOfRowsPerSectionThatUserWants =
                validParameters.numberOfRows
            // Number of sections in each month
//            let numberOfSectionsPerMonth = Int(
//                ceil(
//                    Float(maxNumberOfRowsPerMonth)  /
//                        Float(validParameters.numberOfRows)
//                )
//            )
            // Section represents # of months. section is used as an offset
            // to determine which month to calculate
            for monthIndex in 0 ..< numberOfMonths {
                if let currentMonth = calendar.date(byAdding: .month,
                                                    value: monthIndex,
                                                    to: startMonth) {
                    var numberOfDaysInMonthVariable = calendar.range(
                        of: .day, in: .month, for: currentMonth)!.count
                    let numberOfDaysInMonthFixed = numberOfDaysInMonthVariable
                    var numberOfRowsToGenerateForCurrentMonth = 0
                    var numberOfPreDatesForThisMonth = 0
                    if delegate.preDatesAreGenerated() {
                        numberOfPreDatesForThisMonth =
                            delegate.numberOfPreDatesForMonth(currentMonth)
                        numberOfDaysInMonthVariable +=
                        numberOfPreDatesForThisMonth
                    }
                    if // validParameters.inCellGeneration == true &&
                        validParameters.outCellGeneration == .tillEndOfGrid {
                            numberOfRowsToGenerateForCurrentMonth =
                                maxNumberOfRowsPerMonth
                    } else {
                        let actualNumberOfRowsForThisMonth =
                            Int(ceil(Float(numberOfDaysInMonthVariable) /
                                Float(maxNumberOfDaysInWeek)))
                        numberOfRowsToGenerateForCurrentMonth =
                        actualNumberOfRowsForThisMonth
                    }
                    var numberOfPostDatesForThisMonth = 0
                    let postGeneration = delegate.postDatesAreGenerated()
                    switch postGeneration {
                    case .tillEndOfGrid, .tillEndOfRow:
                        numberOfPostDatesForThisMonth =
                            maxNumberOfDaysInWeek *
                            numberOfRowsToGenerateForCurrentMonth -
                            (numberOfDaysInMonthFixed +
                                numberOfPreDatesForThisMonth)
                        numberOfDaysInMonthVariable +=
                            numberOfPostDatesForThisMonth
                    default:
                        break
                    }
                    // let numberOfDaysInMonthFixed =
                    //     numberOfDaysInMonthVariable
                    var sectionsForTheMonth: [Int] = []
                    var sectionIndexMaps: [Int: Int] = [:]
                    for index in 0..<6 {
                        // Max number of sections in the month
                        if numberOfDaysInMonthVariable < 1 {
                            break
                        }
                        monthIndexMap[section] = monthIndex
                        sectionIndexMaps[section] = index
                        var numberOfDaysInCurrentSection =
                            numberOfRowsPerSectionThatUserWants *
                            maxNumberOfDaysInWeek
                        if numberOfDaysInCurrentSection >
                            numberOfDaysInMonthVariable {
                                numberOfDaysInCurrentSection =
                                    numberOfDaysInMonthVariable
                                // assert(false)
                        }
                        totalDays += numberOfDaysInCurrentSection
                        sectionsForTheMonth
                            .append(numberOfDaysInCurrentSection)
                        numberOfDaysInMonthVariable -=
                            numberOfDaysInCurrentSection
                        section += 1
                    }
                    monthArray.append(Month(
                        startDayIndex: startIndexForMonth,
                        startCellIndex: startCellIndexForMonth,
                        sections: sectionsForTheMonth,
                        preDates: numberOfPreDatesForThisMonth,
                        postDates: numberOfPostDatesForThisMonth,
                        sectionIndexMaps: sectionIndexMaps,
                        rows: numberOfRowsToGenerateForCurrentMonth
                    ))
                    startIndexForMonth += numberOfDaysInMonthFixed
                    startCellIndexForMonth += numberOfDaysInMonthFixed +
                        numberOfPreDatesForThisMonth +
                    numberOfPostDatesForThisMonth
                }
            }
            return (monthArray, monthIndexMap, section, totalDays)
    }

}
