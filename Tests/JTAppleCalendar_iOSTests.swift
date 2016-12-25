//
//  JTAppleCalendar_iOSTests.swift
//  JTAppleCalendar iOSTests
//
//  Created by JayT on 2016-08-10.
//
//

import XCTest
@testable import JTAppleCalendar

class JTAppleCalendar_iOSTests: XCTestCase {
    let calendarView = JTAppleCalendarView()
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
    
    func testRangePositionOnProgrammaticDateSelection() {
        let calendarView = JTAppleCalendarView()
        calendarView.direction = .vertical
        calendarView.scrollingMode = .none
        calendarView.allowsMultipleSelection = true
        calendarView.cellInset = CGPoint.zero
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)

        let controller = CalendarViewTestingController()
        controller.calendar = calendar
        controller.calendarView = calendarView
        _ = controller.view // init viewDidLoad()
        
        let inTenDays = TimeInterval(10 * 24 * 60 * 60)
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.startOfDay(for: Date(timeIntervalSinceNow: inTenDays))
        
        controller.selectDates(fromDate: startDate, toDate: endDate)
        
        XCTAssertEqual(controller.fromDateSelectedPosition, SelectionRangePosition.left)
        XCTAssertEqual(controller.toDateSelectedPosition, SelectionRangePosition.right)
        XCTAssertEqual(controller.middlePositionsCount, 9)
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
        XCTAssertEqual(val.totalSections, 24)
        for index in 0...23 {
            XCTAssertEqual(val.monthMap[index], index)
        }
        XCTAssertEqual(val.totalDays, 42 * 24)
    }

    private typealias LayotGeneratorTestData = (
        configParams: ConfigurationParameters,
        monthsCount: Int,
        monthsMap: Int,
        monthsMapCount: Int,
        totalSectionsCount: Int
    )
    
    private func layoutGeneratorDataProvider() -> [LayotGeneratorTestData] {
        return [
            (ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 2, generateInDates: .off, generateOutDates: .off),
             24, 70, 23, 71),
            (ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 2),
             24, 71, 23, 72),
            (ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 3),
             24, 22, 11, 48),
            (ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 3),
             24, 23, 11, 48),
        ]
    }
    
    func testLayoutGenerator() {
        for testData in layoutGeneratorDataProvider() {
            let layoutGenerator = JTAppleDateConfigGenerator()
            let val = layoutGenerator.setupMonthInfoDataForStartAndEndDate(testData.configParams)
            XCTAssertEqual(val.months.count, testData.monthsCount)
            XCTAssertEqual(val.monthMap[testData.monthsMap], testData.monthsMapCount)
            XCTAssertEqual(val.totalSections, testData.totalSectionsCount)
        }
    }
    
    private typealias ConfigParamsTestData = (
        inDates: InDateCellGeneration,
        outDates: OutDateCellGeneration,
        firstDayOfWeek: DaysOfWeek,
        numberOfRowsFirst: Int,
        hasStrictBoundariesFirst: Bool,
        numberOfRowsSecond: Int,
        hasStrictBoundariesSecond: Bool
    )
    
    private func configParamsDataProvider() -> [ConfigParamsTestData] {
        return [
            (.forAllMonths, .tillEndOfGrid, .sunday, 6, true, 1, false),
//            (.forAllMonths, .tillEndOfGrid, .sunday, 9, true, 100, false),
//            (.forAllMonths, .tillEndOfGrid, .sunday, 10, true, 80, false),
//            (.forAllMonths, .tillEndOfGrid, .sunday, 100, true, 20, false),
//            (.forAllMonths, .tillEndOfGrid, .sunday, 100, true, 20, false),
//            (.forAllMonths, .tillEndOfGrid, .sunday, 200, true, 300, false),
        ]
    }
    
    func testConfigurationParametersDefaultBehaviorsFirst() {
        print("testing default parameters")
        
        for testData in configParamsDataProvider() {
            let paramsFirst = ConfigurationParameters(startDate: Date(), endDate: Date())
            
            XCTAssertEqual(paramsFirst.generateInDates, testData.inDates)
            XCTAssertEqual(paramsFirst.generateOutDates, testData.outDates)
            XCTAssertEqual(paramsFirst.firstDayOfWeek, testData.firstDayOfWeek)
            
            XCTAssertEqual(paramsFirst.numberOfRows, testData.numberOfRowsFirst)
            XCTAssertEqual(paramsFirst.hasStrictBoundaries, testData.hasStrictBoundariesFirst)
            
            let paramsSecond = ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 1)
            XCTAssertEqual(paramsSecond.numberOfRows, testData.numberOfRowsSecond)
            XCTAssertEqual(paramsSecond.hasStrictBoundaries, testData.hasStrictBoundariesSecond)
        }
    }
}

public class CalendarViewTestingController: UIViewController {
    var calendar: Calendar!
    var calendarView: JTAppleCalendarView!
    
    public var fromDate = Date()
    public var toDate = Date()
    
    var fromDateSelectedPosition: SelectionRangePosition? = nil
    var toDateSelectedPosition: SelectionRangePosition? = nil
    var middlePositionsCount: Int = 0

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        // a MUST to make calendarView believe it is already loaded
        calendarView.itemSize = CGFloat(10)
        calendarView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        view.addSubview(calendarView)
    }
    
    func selectDates(fromDate: Date, toDate: Date) {
        self.fromDate = fromDate
        self.toDate = toDate
        middlePositionsCount = 0
        
        calendarView.selectDates(from: fromDate, to: toDate)
    }
}

extension CalendarViewTestingController: JTAppleCalendarViewDataSource {
    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let nextYear = TimeInterval(365 * 24 * 60 * 60)
        let startDate = self.calendar.startOfDay(for: Date())
        let endDate = self.calendar.startOfDay(for: Date(timeIntervalSinceNow: nextYear))
        
        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate,
                                       calendar: self.calendar,
                                       firstDayOfWeek: .monday
        )
    }
}

extension CalendarViewTestingController: JTAppleCalendarViewDelegate {
    public func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        let selectedPosition = cellState.selectedPosition()
        if date == fromDate {
            fromDateSelectedPosition = selectedPosition
        } else if date == toDate {
            toDateSelectedPosition = selectedPosition
        } else if selectedPosition == .middle {
            middlePositionsCount += 1
        }
    }
}
