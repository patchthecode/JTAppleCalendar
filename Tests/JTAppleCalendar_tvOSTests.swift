//
//  JTAppleCalendar_tvOSTests.swift
//  JTAppleCalendar tvOSTests
//
//  Created by JayT on 2016-08-10.
//
//

import XCTest
@testable import JTAppleCalendar

class JTAppleCalendar_tvOSTests: XCTestCase {
    let calendarView = JTAppleCalendarMonthView()
    let formatter: DateFormatter = {
        let aFormatter = DateFormatter()
        aFormatter.dateFormat = "yyyy MM dd"
        return aFormatter
    }()
    
    var startDate = Date()
    var endDate = Date()
    
    
    override func setUp() {
        startDate = formatter.date(from: "2016 01 01")!
        endDate = formatter.date(from: "2017 12 01")!
    }
    
    func testConfigurationParametersDefaultBehavior() {
        print("testing default parameters")
        var params = ConfigurationParameters(startDate: Date(), endDate: Date())
        print("All months should be default")
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        print("Till Grid should be default should be default")
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        print("Rows should be 6")
        XCTAssertEqual(params.numberOfRows, 6)
        print("First day should be sunday")
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        print("strict should be true")
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        print("Rows should be 1")
        XCTAssertEqual(params.numberOfRows, 1)
        print("strict should be false")
        XCTAssertEqual(params.hasStrictBoundaries, false)
    }
    
    func testLayoutGeneratorOnDefaults() {
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate)
        let layoutGenerator = JTAppleDateConfigGenerator()
        let val = layoutGenerator.setupMonthInfoDataForStartAndEndDate(params)
        XCTAssertEqual(val.months.count, 24)
        XCTAssertEqual(val.totalSections,  24)
        for index in 0...23 {
            XCTAssertEqual(val.monthMap[index],  index)
        }
        XCTAssertEqual(val.totalDays,  42 * 24)
    }
    
    func testLayoutGeneratorOnThreeRow() {
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 3)
        let layoutGenerator = JTAppleDateConfigGenerator()
        let val = layoutGenerator.setupMonthInfoDataForStartAndEndDate(params)
        XCTAssertEqual(val.months.count, 24)
        XCTAssertEqual(val.totalSections, 48)
        XCTAssertEqual(val.monthMap[22], 11)
        XCTAssertEqual(val.monthMap[23], 11)
    }
    func testLayoutGeneratorOnTwoRow() {
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 2)
        let layoutGenerator = JTAppleDateConfigGenerator()
        let val = layoutGenerator.setupMonthInfoDataForStartAndEndDate(params)
        XCTAssertEqual(val.months.count, 24)
        XCTAssertEqual(val.monthMap[71], 23)
        XCTAssertEqual(val.totalSections, 72)
    }
    func testLayoutGeneratorWithOffInAndOffOut() {
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 2, generateInDates: .off, generateOutDates: .off)
        let layoutGenerator = JTAppleDateConfigGenerator()
        let val = layoutGenerator.setupMonthInfoDataForStartAndEndDate(params)
        XCTAssertEqual(val.months.count, 24)
        XCTAssertEqual(val.monthMap[70], 23)
        XCTAssertEqual(val.totalSections, 71)
    }
    func testLayoutGeneratorOnDefaultsFirst() {
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate)
        let layoutGenerator = JTAppleDateConfigGenerator()
        let val = layoutGenerator.setupMonthInfoDataForStartAndEndDate(params)
        XCTAssertEqual(val.months.count, 24)
        XCTAssertEqual(val.totalSections, 24)
        for index in 0...23 {
            XCTAssertEqual(val.monthMap[index], index)
        }
        XCTAssertEqual(val.totalDays, 42 * 24)
    }
    
    func testLayoutGeneratorOnThreeRowFirst() {
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 3)
        let layoutGenerator = JTAppleDateConfigGenerator()
        let val = layoutGenerator.setupMonthInfoDataForStartAndEndDate(params)
        XCTAssertEqual(val.months.count, 24)
        XCTAssertEqual(val.totalSections, 48)
        XCTAssertEqual(val.monthMap[22], 11)
        XCTAssertEqual(val.monthMap[23], 11)
    }
    func testLayoutGeneratorOnTwoRowFirst() {
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 2)
        let layoutGenerator = JTAppleDateConfigGenerator()
        let val = layoutGenerator.setupMonthInfoDataForStartAndEndDate(params)
        XCTAssertEqual(val.months.count, 24)
        XCTAssertEqual(val.monthMap[71], 23)
        XCTAssertEqual(val.totalSections, 72)
    }
    func testLayoutGeneratorWithOffInAndOffOutFirst() {
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 2, generateInDates: .off, generateOutDates: .off)
        let layoutGenerator = JTAppleDateConfigGenerator()
        let val = layoutGenerator.setupMonthInfoDataForStartAndEndDate(params)
        XCTAssertEqual(val.months.count, 24)
        XCTAssertEqual(val.monthMap[70], 23)
        XCTAssertEqual(val.totalSections, 71)
    }
    func testConfigurationParametersDefaultBehaviorFirst() {
        var params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertEqual(params.numberOfRows, 6)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertEqual(params.numberOfRows, 1)
        XCTAssertEqual(params.hasStrictBoundaries, false)
    }
    func testConfigurationParametersDefaultBehaviorsFirst() {
        var params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertEqual(params.numberOfRows, 6)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertEqual(params.numberOfRows, 1)
        XCTAssertEqual(params.hasStrictBoundaries, false)
    }
    func testConfigurationParametersDefaultBehaviorssFirst() {
        print("testing default parameters")
        var params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertEqual(params.numberOfRows, 6)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertEqual(params.numberOfRows, 1)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        // first
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertEqual(params.numberOfRows, 6)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertEqual(params.numberOfRows, 1)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        //second
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertEqual(params.numberOfRows, 6)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertEqual(params.numberOfRows, 1)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        // third
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertEqual(params.numberOfRows, 6)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertEqual(params.numberOfRows, 1)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        // 4
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 9)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 100)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        //5
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 10)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 80)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        // 6
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 100)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 20)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        // 7
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 9)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 100)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        // 8
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 10)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 80)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        // 9
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 100)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 20)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        // 10
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 9)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 100)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        //11
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 10)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 80)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        // 12
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 100)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 20)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        
        // 13
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 9)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 100)
        XCTAssertEqual(params.hasStrictBoundaries, false)
        
        // 14
        params = ConfigurationParameters(startDate: Date(), endDate: Date())
        XCTAssertEqual(params.generateInDates, .forAllMonths)
        XCTAssertEqual(params.generateOutDates, .tillEndOfGrid)
        XCTAssertNotEqual(params.numberOfRows, 200)
        XCTAssertEqual(params.firstDayOfWeek, .sunday)
        XCTAssertEqual(params.hasStrictBoundaries, true)
        params = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
        XCTAssertNotEqual(params.numberOfRows, 300)
        XCTAssertEqual(params.hasStrictBoundaries, false)
    }
}
