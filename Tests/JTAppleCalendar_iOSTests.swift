//
//  JTAppleCalendar_iOSTests.swift
//  JTAppleCalendar iOSTests
//
//  Created by JayT on 2016-08-10.
//
//

import XCTest
@testable import JTAppleCalendar

class JTAppleCalendar_iOSTests: XCTestCase, JTAppleCalendarViewDataSource {
    let calendarView = JTAppleCalendarView()
    let formatter = DateFormatter()
    let calendar = Calendar(identifier: .gregorian)
    var numberOfRows = 6
    var firstDate = "2016 01 01"
    var secondDate = "2017 12 01"
    
    override func setUp() {
        super.setUp()
        formatter.dateFormat = "yyyy MM dd"
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCountOfMonths() {
        print("Testing to see if setupMonthInfoDataForStartAndEndDate() gives valid month data even when number of rows change")
        firstDate = "2016 01 01"
        secondDate = "2017 01 01"
        calendarView.dataSource = self
        
        var monthData = calendarView.setupMonthInfoDataForStartAndEndDate()
        XCTAssert(monthData.count == 13)
        
        numberOfRows = 3
        calendarView.reloadData()
        
        monthData = calendarView.setupMonthInfoDataForStartAndEndDate()
        XCTAssert(monthData.count == 26)
        
        numberOfRows = 2
        calendarView.reloadData()
        
        monthData = calendarView.setupMonthInfoDataForStartAndEndDate()
        XCTAssert(monthData.count == 39)
        
        numberOfRows = 1
        calendarView.reloadData()
        
        monthData = calendarView.setupMonthInfoDataForStartAndEndDate()
        XCTAssert(monthData.count == 78)
    }
    
    func testSegmentFunction() {
        print("Testing to see if degment function returns valid data")
        firstDate = "2016 01 01"
        secondDate = "2016 01 01"
        numberOfRows = 6
        
        calendarView.dataSource = self
        calendarView.reloadData()
        let date = formatter.date(from: "2016 01 01")!
        
        var month = calendarView.dateFromSection(0)!.month
        
        var compMonth = calendar.component(.month, from: date)
        XCTAssert(month == compMonth)
        
        numberOfRows = 3
        calendarView.reloadData()
        
        for index in 0...1 {
            month = calendarView.dateFromSection(index)!.month
            compMonth = calendar.component(.month, from: date)
            XCTAssert(month == compMonth)
        }
        
        numberOfRows = 2
        calendarView.reloadData()
        
        for index in 0...2 {
            month = calendarView.dateFromSection(index)!.month
            compMonth = calendar.component(.month, from: date)
            XCTAssert(month == compMonth)
        }
        
        numberOfRows = 1
        calendarView.reloadData()
        
        for index in 0...5 {
            month = calendarView.dateFromSection(index)!.month
            compMonth = calendar.component(.month, from: date)
            XCTAssert(month == compMonth)
        }
    }
    
//    func testChangeRowToOne() {
//        
//        // This is an example of a performance test case.
////        self.measureBlock {
//            // Put the code you want to measure the time of here.
////        }
//    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> (startDate: Date, endDate: Date, numberOfRows: Int, calendar: Calendar) {
        let aFirstDate = formatter.date(from: firstDate)
        let aSecondDate = formatter.date(from: secondDate)
        let aCalendar = Calendar.current // Properly configure your calendar to your time zone here
        return (startDate: aFirstDate!, endDate: aSecondDate!, numberOfRows: numberOfRows, calendar: aCalendar)
    }
    
}
