//
//  Date+RangeGapFix.swift
//  SampleJTAppleCalendar
//
//  Created by Paul Addy on 29/3/23.
//  Copyright © 2023 OsTech. All rights reserved.
//

import Foundation

// MARK: - ADCalendar control specific date extension
public extension Date {
//    var day: Int {
//        let components = Calendar(identifier: .gregorian).dateComponents([.day], from: self)
//        guard let day = components.day else {
//            assertionFailure(ErrorStrings.missingData.rawValue)
//            return 1
//        }
//        return day
//    }
//
    func isSameDay(as date: Date) -> Bool {
        Calendar(identifier: .gregorian).isDate(self, equalTo: date, toGranularity: .day)
    }

    func isToday() -> Bool {
        isSameDay(as: Calendar(identifier: .gregorian).startOfDay(for: Date()))
    }

    /// Unix Epoch day, Jan 1st, 1970.
    static var unixEpochDay: Date {
        if #available(iOS 13.0, *) {
            return Date().advanced(by: -Date().timeIntervalSince1970)
        } else {
            // Fallback on earlier versions
            assertionFailure("missingData")
            return Date()
        }
    }

    /// 127 years in the future
    ///
    /// Note: Highest usable computed value by JTAppelCalendar. If we use Int16.max, then ressources will be severely compromised.
    static var maxJTAppleCalendarDate: Date {
        guard let date = Calendar(identifier: .gregorian).date(byAdding: .year, value: Int(Int8.max), to: Date()) else {
            assertionFailure("missingData")
            return Date()
        }
        return date
    }

//    func add(days: Int) -> Date {
//        guard let date = Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self) else {
//            assertionFailure(ErrorStrings.missingData.rawValue)
//            return Date()
//        }
//        return date
//    }
//
//    func add(months: Int) -> Date {
//        guard let date = Calendar(identifier: .gregorian).date(byAdding: .month, value: months, to: self) else {
//            assertionFailure(ErrorStrings.missingData.rawValue)
//            return Date()
//        }
//        return date
//    }
//
    var monthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: self)
    }
//
//    var monthCalendar: Int {
//        let components = Calendar(identifier: .gregorian).dateComponents([.month], from: self)
//        guard let month = components.month else {
//            assertionFailure(ErrorStrings.missingData.rawValue)
//            return 1
//        }
//        return month
//    }
//
    var yearCalendar: Int {
        let components = Calendar(identifier: .gregorian).dateComponents([.year], from: self)
        guard let year = components.year else {
            assertionFailure(ErrorStrings.missingData.rawValue)
            return 1
        }
        return year
    }
//
    var startOfMonth: Date {
        guard let date = Calendar(identifier: .gregorian).date(
            from: Calendar(identifier: .gregorian).dateComponents(
                [.year, .month],
                from: Calendar(identifier: .gregorian).startOfDay(
                    for: self
                )
            )
        ) else {
            assertionFailure(ErrorStrings.missingData.rawValue)
            return Date()
        }
        return date
    }

    var endOfMonth: Date {
        guard let endOfMonth = Calendar(identifier: .gregorian).date(
            byAdding: DateComponents(month: 1, day: -1),
            to: self.startOfMonth
        ) else {
            assertionFailure(ErrorStrings.missingData.rawValue)
            return Date()
        }
        return endOfMonth
    }
//
//    static func isMonthYearEqual(date1: Date, date2: Date) -> Bool {
//        return date1.monthCalendar == date2.monthCalendar && date1.yearCalendar == date2.yearCalendar
//    }
}
