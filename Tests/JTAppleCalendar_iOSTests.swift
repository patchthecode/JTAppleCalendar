//
//  JTAppleCalendar_iOSTests.swift
//  JTAppleCalendar iOSTests
//
//  Created by JayT on 2016-08-10.
//
//

// import XCTest
// @testable import JTAppleCalendar
//
// class JTAppleCalendar_iOSTests: XCTestCase, JTAppleCalendarViewDataSource {
//    let calendarView = JTAppleCalendarView()
//    let formatter = NSDateFormatter()
//    let calendar =
//        NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
//    var numberOfRows = 6
//    var firstDate: Date!
//    var secondDate: Date!
//    var returnConfiguration: (startDate: Date, endDate: Date,
//                              numberOfRows: Int, calendar: Calendar,
//                              generateInDates: Bool,
//                              generateOutDates: OutDateCellGeneration)?
//    override func setUp() {
//        super.setUp()
//        formatter.dateFormat = "yyyy MM dd"
//    }
//    override func tearDown() {
//        // Put teardown code here. This method is called after the
//        // invocation of each test method in the class.
//        super.tearDown()
//    }
//    func testCheckingCalendarGeneratedData() {
//        print("Testing to see if setupMonthInfoDataForStartAndEndDate() " +
//            "gives valid month data even when number of rows change")
//        firstDate = formatter.dateFromString("2016 02 01")!
//        secondDate = formatter.dateFromString("2016 04 01")!
//        returnConfiguration = (startDate: firstDate, endDate: secondDate,
//                               numberOfRows: numberOfRows,
//                               calendar: calendar!, generateInDates: false,
//                               generateOutDates: .tillEndOfGrid)
//        calendarView.dataSource = self
//        let monthData = calendarView.setupMonthInfoDataForStartAndEndDate()
//        print(monthData)
// //        var months: [month]
// //        var totalSections: Int
// //        var monthMap: [Int:Int]
// //        var totalDays: Int
//        XCTAssert(monthData.months.count == 3,
//                  "Verifying if there are 3 months")
//        XCTAssert(monthData.totalDays == 126,
//                  "Verifying number of generated cells")
//        XCTAssert(monthData.totalSections == 3,
//                  "Verifying number of total sections")
//    }
// //    func test() {
// //    }
// //    func testSegmentFunction() {
// //        print("Testing to see if degment function returns valid data")
// //        firstDate = "2016 01 01"
// //        secondDate = "2016 01 01"
// //        numberOfRows = 6
// //        calendarView.dataSource = self
// //        calendarView.reloadData()
// //        let date = formatter.dateFromString("2016 01 01")!
// //        var month = calendarView.dateFromSection(0)!.month
// //        var compMonth = calendar!.component(.Month, fromDate: date)
// //        XCTAssert(month == compMonth)
// //        numberOfRows = 3
// //        calendarView.reloadData()
// //        for index in 0...1 {
// //            month = calendarView.dateFromSection(index)!.month
// //            compMonth = calendar!.component(.Month, fromDate: date)
// //            XCTAssert(month == compMonth)
// //        }
// //        numberOfRows = 2
// //        calendarView.reloadData()
// //        for index in 0...2 {
// //            month = calendarView.dateFromSection(index)!.month
// //            compMonth = calendar!.component(.Month, fromDate: date)
// //            XCTAssert(month == compMonth)
// //        }
// //        numberOfRows = 1
// //        calendarView.reloadData()
// //        for index in 0...5 {
// //            month = calendarView.dateFromSection(index)!.month
// //            compMonth = calendar!.component(.Month, fromDate: date)
// //            XCTAssert(month == compMonth)
// //        }
// //    }
// //    func testChangeRowToOne() {
// //        // This is an example of a performance test case.
// /// /        self.measureBlock {
// //            // Put the code you want to measure the time of here.
// /// /        }
// //    }
//    func configureCalendar(calendar: JTAppleCalendarView) ->
//        (startDate: Date, endDate: Date, numberOfRows: Int,
//        calendar: Calendar, generateInDates: Bool,
//        generateOutDates: OutDateCellGeneration) {
//            return returnConfiguration!
//            return (startDate: firstDate!, endDate: secondDate,
//                    numberOfRows: numberOfRows, calendar: aCalendar,
//                    generateInDates: false, generateOutDates: .tillEndOfRow)
//            return (startDate: firstDate!, endDate: secondDate,
//                    numberOfRows: numberOfRows, calendar: aCalendar,
//                    generateInDates: false, generateOutDates: .off)
//            return (startDate: firstDate!, endDate: secondDate,
//                    numberOfRows: numberOfRows, calendar: aCalendar,
//                    generateInDates: true, generateOutDates: .tillEndOfGrid)
//            return (startDate: firstDate!, endDate: secondDate,
//                    numberOfRows: numberOfRows, calendar: aCalendar,
//                    generateInDates: true, generateOutDates: .off)
//            return (startDate: firstDate!, endDate: secondDate,
//                    numberOfRows: numberOfRows, calendar: aCalendar,
//                    generateInDates: true, generateOutDates: .off)
//    }
// }
