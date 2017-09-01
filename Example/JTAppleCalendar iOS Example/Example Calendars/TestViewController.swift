//
//  TestViewController.swift
//  JTAppleCalendar iOS
//
//  Created by Jeron Thomas on 2017-07-11.
//

import UIKit
import JTAppleCalendar

class TestViewController: UIViewController {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet var calendarView: JTAppleCalendarView!
    @IBOutlet var theView: UIView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }

    }
    
    @IBAction func zeroHeight(_ sender: UIButton) {
        let frame = calendarView.frame
        calendarView.frame = CGRect(x: frame.origin.x,
                                    y: frame.origin.y,
                                    width: frame.width,
                                    height: 0)
        calendarView.reloadData()
    }
    @IBAction func twoHeight(_ sender: UIButton) {
        let frame = calendarView.frame
        calendarView.frame = CGRect(x: frame.origin.x,
                                    y: frame.origin.y,
                                    width: frame.width,
                                    height: 50)
        calendarView.reloadData()
    }
    @IBAction func twoHundredHeight(_ sender: UIButton) {
        let frame = calendarView.frame
        calendarView.frame = CGRect(x: frame.origin.x,
                                    y: frame.origin.y,
                                    width: frame.width,
                                    height: 200)
        calendarView.reloadData()
    }
    
    @IBAction func zeroHeightView(_ sender: UIButton) {
        viewHeightConstraint.constant = 0
        calendarView.reloadData()

    }
    @IBAction func twoHeightView(_ sender: UIButton) {
        viewHeightConstraint.constant = 50
        calendarView.reloadData()
    }
    @IBAction func twoHundredHeightView(_ sender: UIButton) {
        viewHeightConstraint.constant = 200
        calendarView.reloadData()
    }
    
    @IBAction func selectOneDate(_ sender: UIButton) {
        formatter.dateFormat = "yyyy MM dd"
        let date = formatter.date(from: "2017 01 03")!
        calendarView.selectDates([date])
        calendarView.debugThis()
    }
    @IBAction func selectOtherDate(_ sender: UIButton) {
        formatter.dateFormat = "yyyy MM dd"
        let date = formatter.date(from: "2017 01 07")!
        calendarView.selectDates([date])
        calendarView.debugThis()
    }
    
    @IBAction func selectOneMonth(_ sender: UIButton) {
        formatter.dateFormat = "yyyy MM dd"
        let date = formatter.date(from: "2017 02 12")!
        calendarView.selectDates([date])
        calendarView.debugThis()
    }
    @IBAction func reload(_ sender: UIButton) {
        calendarView.reloadData()
    }
    
    @IBAction func debugthis(_ sender: UIButton) {
        calendarView.debugThis()
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = Calendar.current.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = Calendar.current.component(.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else { return }
        handleCellTextColor(view: myCustomCell, cellState: cellState)
        handleCellSelection(view: myCustomCell, cellState: cellState)
    }
    
    func handleCellSelection(view: CellView, cellState: CellState) {
        if cellState.isSelected {
            view.backgroundColor = UIColor.red
        } else {
            view.backgroundColor = UIColor.white
        }
    }
    func handleCellTextColor(view: CellView, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            view.dayLabel.textColor = UIColor.black
        } else {
            view.dayLabel.textColor = UIColor.gray
        }
    }
    
    var iii: Date?
}


extension TestViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "cell", for: indexPath) as! CellView
        configureCell(view: cell, cellState: cellState)
        if cellState.text == "1" {
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: date)
            cell.dayLabel .text = "\(month) \(cellState.text)"
        } else {
            cell.dayLabel .text = cellState.text
        }
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2030 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,endDate: endDate)
        return parameters
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
        iii = visibleDates.monthDates.first?.date
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        calendarView.viewWillTransition(to: size, with: coordinator, anchorDate: iii)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    
}

