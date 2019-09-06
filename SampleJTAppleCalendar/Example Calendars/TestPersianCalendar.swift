//
//  TestPersianCalendar.swift
//  SampleCalendar
//
//  Copyright © 2017 Aminous. All rights reserved.
//

import JTAppleCalendar
import UIKit

class TestPersianCalendar: UIViewController {
    @IBOutlet var calendarView: JTACMonthView!

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "hh:mm"
        return dateFormatter
    }()

    let persianDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .persian)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCalendarView()
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func handleCellSelected(cell: JTACDayCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else { return }
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }

    func handleCellTextColor(cell: JTACDayCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else { return }
        if cellState.isSelected {
            validCell.dateLabel.textColor = UIColor.white
        } else {
            let today = Date()
            persianDateFormatter.dateFormat = "yyyy MM dd"
            let todayDateStr = persianDateFormatter.string(from: today)
            dateFormatter.dateFormat = "yyyy MM dd"
            let cellDateStr = dateFormatter.string(from: cellState.date)

            if todayDateStr == cellDateStr {
                validCell.dateLabel.textColor = UIColor.yellow
            } else {
                if cellState.dateBelongsTo == .thisMonth {
                    validCell.dateLabel.textColor = UIColor.white
                } else { // i.e. case it belongs to inDate or outDate
                    validCell.dateLabel.textColor = UIColor.gray
                }
            }
        }
    }

    func setupCalendarView() {
        // Setup calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
    }
}

extension TestPersianCalendar: JTACMonthViewDataSource {
    func configureCalendar(_: JTACMonthView) -> ConfigurationParameters {
        let persianCalendar = Calendar(identifier: .persian)

        let testFotmatter = DateFormatter()
        testFotmatter.dateFormat = "yyyy/MM/dd"
        testFotmatter.timeZone = persianCalendar.timeZone
        testFotmatter.locale = persianCalendar.locale

        let startDate = testFotmatter.date(from: "2017/01/01")!
        let endDate = testFotmatter.date(from: "2017/09/30")!

        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, calendar: persianCalendar)
        return parameters
    }
}

extension TestPersianCalendar: JTACMonthViewDelegate {
    func calendar(_: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt _: Date, cellState: CellState, indexPath _: IndexPath) {
        // The code here is the same as cellForItem function
        let cell = cell as! CellView
        cell.dayLabel.text = cellState.text

        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTACMonthView, cellForItemAt _: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "mainInfo_CalenderCell", for: indexPath) as! CellView
        cell.dayLabel.text = cellState.text

        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)

        return cell
    }

    func calendar(_: JTACMonthView, didSelectDate _: Date, cell: JTACDayCell?, cellState: CellState) {
        print(cellState.dateBelongsTo)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
    }

    func calendar(_: JTACMonthView, didDeselectDate _: Date, cell: JTACDayCell?, cellState: CellState) {
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
    }
}

class CalendarCell: JTACDayCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var selectedView: UIView!
}
