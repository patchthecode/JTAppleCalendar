//
//  JTAppleCalendar_iOSTests.swift
//  JTAppleCalendar iOSTests
//
//  Created by JayT on 2016-08-10.
//
//

import XCTest
@testable import JTAppleCalendar

class JTAppleCalendar_iOSTests: XCTestCas(width, cellSize.height)e {
    let calendarView = JTACMonthView()
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
    
    func testVisibleDates() {
        let calendarView = JTACMonthView()
        calendarView.scrollDirection = .vertical
        calendarView.scrollingMode = .none
        calendarView.allowsMultipleSelection = true
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let controller = CalendarViewTestingController()
        controller.calendar = calendar
        controller.calendarView = calendarView
        _ = controller.view // init viewDidLoad()
    }
}

public class CalendarViewTestingController: UIViewController {
    var calendar: Calendar!
    var calendarView: JTACMonthView!

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.ibCalendarDelegate = self
        calendarView.ibCalendarDataSource = self
        let myNib = UINib(nibName: "CellView", bundle: Bundle.main)
        calendarView.register(TestCellView.self, forCellWithReuseIdentifier: "Cell")
        
        // a MUST to make calendarView believe it is already loaded
        calendarView.cellSize = 10
        calendarView.frame = view.frame
        
        view.addSubview(calendarView)
        
        
        
        calendarView.layoutSubviews()
        calendarView.visibleDates { segInfo in
            print(segInfo.monthDates)
        }
        print("finished before done")
    }
}

extension CalendarViewTestingController: JTACMonthViewDataSource {
    public func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = Date()
        
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
}

extension CalendarViewTestingController: JTACMonthViewDelegate {
    public func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "Cell", for: indexPath) as! TestCellView
        return cell
    }
}

class TestCellView: JTACDayCell {
}










