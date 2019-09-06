//
//  TestRangeSelectionViewController.swift
//  JTAppleCalendar iOS
//
//  Created by Jay Thomas on 2018-08-07.
//

import JTAppleCalendar
import UIKit

class TestRangeSelectionViewController: UIViewController {
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var calendarView: JTACMonthView!
    let df = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.visibleDates { visibleDates in
            self.setupMonthLabel(date: visibleDates.monthDates.first!.date)
        }

        calendarView.allowsMultipleSelection = true
        calendarView.allowsMultipleSelection = true
    }

    func setupMonthLabel(date: Date) {
        df.dateFormat = "MMM"
        monthLabel.text = df.string(from: date)
    }

    func handleConfiguration(cell: JTACDayCell?, cellState: CellState) {
        guard let cell = cell as? TestRangeSelectionViewControllerCell else { return }
        handleCellColor(cell: cell, cellState: cellState)
        handleCellSelection(cell: cell, cellState: cellState)
    }

    func handleCellColor(cell: TestRangeSelectionViewControllerCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.label.textColor = .black
        } else {
            cell.label.textColor = .gray
        }
    }

    func handleCellSelection(cell: TestRangeSelectionViewControllerCell, cellState: CellState) {
        cell.selectedView.isHidden = !cellState.isSelected
        if #available(iOS 11.0, *) {
            switch cellState.selectedPosition() {
            case .left:
                cell.selectedView.layer.cornerRadius = 20
                cell.selectedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            case .middle:
                cell.selectedView.layer.cornerRadius = 0
                cell.selectedView.layer.maskedCorners = []
            case .right:
                cell.selectedView.layer.cornerRadius = 20
                cell.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            case .full:
                cell.selectedView.layer.cornerRadius = 20
                cell.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
            default: break
            }
        }
    }
}

extension TestRangeSelectionViewController: JTACMonthViewDelegate, JTACMonthViewDataSource {
    func calendar(_: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt _: Date, cellState: CellState, indexPath _: IndexPath) {
        handleConfiguration(cell: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "cell", for: indexPath) as! TestRangeSelectionViewControllerCell
        cell.label.text = cellState.text
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }

    func calendar(_: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupMonthLabel(date: visibleDates.monthDates.first!.date)
    }

    func calendar(_: JTACMonthView, didSelectDate _: Date, cell: JTACDayCell?, cellState: CellState) {
        handleConfiguration(cell: cell, cellState: cellState)
    }

    func calendar(_: JTACMonthView, didDeselectDate _: Date, cell: JTACDayCell?, cellState: CellState) {
        handleConfiguration(cell: cell, cellState: cellState)
    }

    func configureCalendar(_: JTACMonthView) -> ConfigurationParameters {
        let df = DateFormatter()
        df.dateFormat = "yyyy MM dd"

        let startDate = df.date(from: "2017 01 01")!
        let endDate = df.date(from: "2017 12 31")!

        let parameter = ConfigurationParameters(startDate: startDate,
                                                endDate: endDate,
                                                numberOfRows: 6,
                                                generateInDates: .forAllMonths,
                                                generateOutDates: .tillEndOfGrid,
                                                firstDayOfWeek: .sunday)
        return parameter
    }
}

class TestRangeSelectionViewControllerCell: JTACDayCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var selectedView: UIView!
}
