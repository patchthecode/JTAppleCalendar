//
//  CalendarStructs.swift
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
    public let dateSection: () -> (range: (start: Date, end: Date), month: Int, rowCount: Int)
    /// returns the position of a selection in the event you wish to do range selection
    public let selectedPosition: () -> SelectionRangePosition
    /// returns the cell.
    /// Useful if you wish to display something at the cell's frame/position
    public var cell: () -> JTACDayCell?
    /// Shows if a cell's selection/deselection was done either programatically or by the user
    /// This variable is guranteed to be non-nil inside of a didSelect/didDeselect function
    public var selectionType: SelectionType? = nil
}

/// Defines the parameters which configures the calendar.
public struct ConfigurationParameters {
    /// The start date boundary of your calendar
    var startDate: Date
    /// The end-date boundary of your calendar
    var endDate: Date
    /// Number of rows you want to calendar to display per date section
    var numberOfRows: Int
    /// Your calendar() Instance
    var calendar: Calendar
    /// Describes the types of in-date cells to be generated.
    var generateInDates: InDateCellGeneration
    /// Describes the types of out-date cells to be generated.
    var generateOutDates: OutDateCellGeneration
    /// Sets the first day of week
    var firstDayOfWeek: DaysOfWeek
    /// Determine if dates of a month should stay in its section 
    /// or if it can flow into another months section. This value is ignored
    /// if your calendar has registered headers
    var hasStrictBoundaries: Bool
    
    /// init-function
    public init(startDate: Date,
                endDate: Date,
                numberOfRows: Int = 6,
                calendar: Calendar = Calendar.current,
                generateInDates: InDateCellGeneration = .forAllMonths,
                generateOutDates: OutDateCellGeneration = .tillEndOfGrid,
                firstDayOfWeek: DaysOfWeek? = nil,
                hasStrictBoundaries: Bool? = nil) {
        self.startDate = startDate
        self.endDate = endDate

        if numberOfRows > 0 && numberOfRows < 7 {
            self.numberOfRows = numberOfRows
        } else {
            self.numberOfRows = 6
        }

        if let nonNilHasStrictBoundaries = hasStrictBoundaries {
            self.hasStrictBoundaries = nonNilHasStrictBoundaries
        } else {
            self.hasStrictBoundaries = self.numberOfRows > 1 ? true : false
        }
        self.calendar = calendar
        self.generateInDates = generateInDates
        self.generateOutDates = generateOutDates
        
        if let firstDayOfWeek = firstDayOfWeek {
            self.firstDayOfWeek = firstDayOfWeek
        } else {
            self.firstDayOfWeek = DaysOfWeek(rawValue: calendar.firstWeekday) ?? .sunday
        }
    }
}

public struct MonthSize {
    var defaultSize: CGFloat
    var months: [CGFloat:[MonthsOfYear]]?
    var dates: [CGFloat: [Date]]?
    
    public init(defaultSize: CGFloat, months: [CGFloat:[MonthsOfYear]]? = nil, dates: [CGFloat: [Date]]? = nil) {
        self.defaultSize = defaultSize
        self.months = months
        self.dates = dates
    }
}

struct CalendarData {
    var months: [Month]
    var totalSections: Int
    var sectionToMonthMap: [Int: Int]
    var totalDays: Int
}

/// Defines a month structure.
public struct Month {
    /// Index of the month
    let index: Int
    
    /// Start index day for the month.
    /// The start is total number of days of previous months
    let startDayIndex: Int

    /// Start cell index for the month.
    /// The start is total number of cells of previous months
    let startCellIndex: Int

    /// The total number of items in this array are the total number
    /// of sections. The actual number is the number of items in each section
    let sections: [Int]

    /// Number of inDates for this month
    public let inDates: Int

    /// Number of outDates for this month
    public let outDates: Int

    /// Maps a section to the index in the total number of sections
    let sectionIndexMaps: [Int: Int]

    /// Number of rows for the month
    public let rows: Int
    
    /// Name of the month
    public let name: MonthsOfYear

    // Return the total number of days for the represented month
    public let numberOfDaysInMonth: Int

    // Return the total number of day cells
    // to generate for the represented month
    var numberOfDaysInMonthGrid: Int {
        return numberOfDaysInMonth + inDates + outDates
    }

    var startSection: Int {
        return sectionIndexMaps.keys.min()!
    }
    
    // Return the section in which a day is contained
    func indexPath(forDay number: Int) -> IndexPath? {
        let sectionInfo = sectionFor(day: number)
        let externalSection = sectionInfo.externalSection
        let internalSection = sectionInfo.internalSection
        let dateOfStartIndex = sections[0..<internalSection].reduce(0, +) - inDates + 1
        let itemIndex = number - dateOfStartIndex

        return IndexPath(item: itemIndex, section: externalSection)
    }
    
    private func sectionFor(day: Int) -> (externalSection: Int, internalSection: Int) {
        var variableNumber = day
        let possibleSection = sections.firstIndex {
            let retval = variableNumber + inDates <= $0
            variableNumber -= $0
            return retval
            }!
        return (sectionIndexMaps.key(for: possibleSection)!, possibleSection)
    }

    // Return the number of rows for a section in the month
    func numberOfRows(for section: Int, developerSetRows: Int) -> Int {
        var retval: Int
        guard let theSection = sectionIndexMaps[section] else {
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
    
    func boundaryIndicesFor(section: Int) -> (startIndex: Int, endIndex: Int)? {
        // Check internal sections to see
        if !(0..<sections.count ~=  section) {
            return nil
        }
        let startIndex = section == 0 ? inDates : 0
        var endIndex =  sections[section] - 1
        if section + 1  == sections.count {
            endIndex -= inDates + 1
        }
        return (startIndex: startIndex, endIndex: endIndex)
    }
}

class JTAppleDateConfigGenerator {
    
    static let shared =  JTAppleDateConfigGenerator()
    private init() {}
    
    func setupMonthInfoDataForStartAndEndDate(_ parameters: ConfigurationParameters)
        -> (months: [Month], monthMap: [Int: Int], totalSections: Int, totalDays: Int) {
            let differenceComponents = parameters.calendar.dateComponents([.month], from: parameters.startDate, to: parameters.endDate)
            let numberOfMonths = differenceComponents.month! + 1
            // if we are for example on the same month
            // and the difference is 0 we still need 1 to display it
            var monthArray: [Month] = []
            var monthIndexMap: [Int: Int] = [:]
            var section = 0
            var startIndexForMonth = 0
            var startCellIndexForMonth = 0
            var totalDays = 0
            let numberOfRowsPerSectionThatUserWants = parameters.numberOfRows
            // Section represents # of months. section is used as an offset
            // to determine which month to calculate
            
            // Track the month name index
            var monthNameIndex = parameters.calendar.component(.month, from: parameters.startDate) - 1
            let allMonthsOfYear: [MonthsOfYear] = [.jan, .feb, .mar, .apr, .may, .jun, .jul, .aug, .sep, .oct, .nov, .dec]
            
            for monthIndex in 0 ..< numberOfMonths {
                if let currentMonthDate = parameters.calendar.date(byAdding: .month, value: monthIndex, to: parameters.startDate) {
                    var numberOfDaysInMonthVariable = parameters.calendar.range(of: .day, in: .month, for: currentMonthDate)!.count
                    let numberOfDaysInMonthFixed = numberOfDaysInMonthVariable
                    var numberOfRowsToGenerateForCurrentMonth = 0
                    var numberOfPreDatesForThisMonth = 0
                    let predatesGeneration = parameters.generateInDates
                    if predatesGeneration != .off {
                        numberOfPreDatesForThisMonth = numberOfInDatesForMonth(currentMonthDate, firstDayOfWeek: parameters.firstDayOfWeek, calendar: parameters.calendar)
                        numberOfDaysInMonthVariable += numberOfPreDatesForThisMonth
                        if predatesGeneration == .forFirstMonthOnly && monthIndex != 0 {
                            numberOfDaysInMonthVariable -= numberOfPreDatesForThisMonth
                            numberOfPreDatesForThisMonth = 0
                        }
                    }
                    
                    if parameters.generateOutDates == .tillEndOfGrid {
                        numberOfRowsToGenerateForCurrentMonth = maxNumberOfRowsPerMonth
                    } else {
                        let actualNumberOfRowsForThisMonth = Int(ceil(Float(numberOfDaysInMonthVariable) / Float(maxNumberOfDaysInWeek)))
                        numberOfRowsToGenerateForCurrentMonth = actualNumberOfRowsForThisMonth
                    }
                    var numberOfPostDatesForThisMonth = 0
                    let postGeneration = parameters.generateOutDates
                    switch postGeneration {
                    case .tillEndOfGrid, .tillEndOfRow:
                        numberOfPostDatesForThisMonth =
                            maxNumberOfDaysInWeek * numberOfRowsToGenerateForCurrentMonth - (numberOfDaysInMonthFixed + numberOfPreDatesForThisMonth)
                        numberOfDaysInMonthVariable += numberOfPostDatesForThisMonth
                    default:
                        break
                    }
                    var sectionsForTheMonth: [Int] = []
                    var sectionIndexMaps: [Int: Int] = [:]
                    for index in 0..<6 {
                        // Max number of sections in the month
                        if numberOfDaysInMonthVariable < 1 {
                            break
                        }
                        monthIndexMap[section] = monthIndex
                        sectionIndexMaps[section] = index
                        var numberOfDaysInCurrentSection = numberOfRowsPerSectionThatUserWants * maxNumberOfDaysInWeek
                        if numberOfDaysInCurrentSection > numberOfDaysInMonthVariable {
                            numberOfDaysInCurrentSection = numberOfDaysInMonthVariable
                            // assert(false)
                        }
                        totalDays += numberOfDaysInCurrentSection
                        sectionsForTheMonth.append(numberOfDaysInCurrentSection)
                        numberOfDaysInMonthVariable -= numberOfDaysInCurrentSection
                        section += 1
                    }
                    monthArray.append(Month(
                        index: monthIndex,
                        startDayIndex: startIndexForMonth,
                        startCellIndex: startCellIndexForMonth,
                        sections: sectionsForTheMonth,
                        inDates: numberOfPreDatesForThisMonth,
                        outDates: numberOfPostDatesForThisMonth,
                        sectionIndexMaps: sectionIndexMaps,
                        rows: numberOfRowsToGenerateForCurrentMonth,
                        name: allMonthsOfYear[monthNameIndex],
                        numberOfDaysInMonth: numberOfDaysInMonthFixed
                    ))
                    startIndexForMonth += numberOfDaysInMonthFixed
                    startCellIndexForMonth += numberOfDaysInMonthFixed + numberOfPreDatesForThisMonth + numberOfPostDatesForThisMonth
                    
                    // Increment month name
                    monthNameIndex += 1
                    if monthNameIndex > 11 { monthNameIndex = 0 }
                }
            }
            return (monthArray, monthIndexMap, section, totalDays)
    }
    
    private func numberOfInDatesForMonth(_ date: Date, firstDayOfWeek: DaysOfWeek, calendar: Calendar) -> Int {
        let firstDayCalValue: Int
        switch firstDayOfWeek {
        case .monday: firstDayCalValue = 6
        case .tuesday: firstDayCalValue = 5
        case .wednesday: firstDayCalValue = 4
        case .thursday: firstDayCalValue = 10
        case .friday: firstDayCalValue = 9
        case .saturday: firstDayCalValue = 8
        default: firstDayCalValue = 7
        }
        
        var firstWeekdayOfMonthIndex = calendar.component(.weekday, from: date)
        firstWeekdayOfMonthIndex -= 1
        // firstWeekdayOfMonthIndex should be 0-Indexed
        // push it modularly so that we take it back one day so that the
        // first day is Monday instead of Sunday which is the default
        return (firstWeekdayOfMonthIndex + firstDayCalValue) % maxNumberOfDaysInWeek
    }
}

/// Contains the information for visible dates of the calendar.
public struct DateSegmentInfo {
    /// Visible pre-dates
    public let indates: [(date: Date, indexPath: IndexPath)]
    /// Visible month-dates
    public let monthDates: [(date: Date, indexPath: IndexPath)]
    /// Visible post-dates
    public let outdates: [(date: Date, indexPath: IndexPath)]
}

struct SelectedCellData {
    let indexPath: IndexPath
    let date: Date
    var counterIndexPath: IndexPath?
    let cellState: CellState
    
    enum DateOwnerCategory {
        case inDate, outDate, monthDate
    }
    
    var dateBelongsTo: DateOwnerCategory {
        switch cellState.dateBelongsTo {
        case .thisMonth: return .monthDate
        case .previousMonthOutsideBoundary, .previousMonthWithinBoundary: return .inDate
        case .followingMonthWithinBoundary, .followingMonthOutsideBoundary: return .outDate
        }
    }
    
    init(indexPath: IndexPath, counterIndexPath: IndexPath? = nil, date: Date, cellState: CellState) {
        self.indexPath        = indexPath
        self.date             = date
        self.cellState        = cellState
        self.counterIndexPath = counterIndexPath
    }
}
