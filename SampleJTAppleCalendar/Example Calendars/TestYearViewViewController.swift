//
//  TestYearViewViewController.swift
//  JTAppleCalendar
//
//  Created by JayT on 2019-05-11.
//

import UIKit
import JTAppleCalendar

class TestYearViewViewController: UIViewController {
    @IBOutlet var calendarView: JTACYearView!
    @IBOutlet var scrollToTodayButton: UIButton!
    @IBOutlet var monthSelectLabel: UILabel!
    let f = DateFormatter()
    
    override func viewDidLoad() {
        calendarView.calendarDataSource  = self
        calendarView.calendarDelegate  = self
        super.viewDidLoad()
        self.monthSelectLabel.text = "Click to select month"
    }
    
    @IBAction func scrollToToday(_ sender: UIButton) {
        calendarView.scrollToDate(Date(), at: .top , animated: true)
    }
    
}


extension TestYearViewViewController: JTACYearViewDelegate, JTACYearViewDataSource {
    // Drawing for a whole month cell
    func calendar(_ calendar: JTACYearView, cellFor item: Any, at date: Date, indexPath: IndexPath) -> JTACMonthCell {
        if item is Month {
            let cell = calendar.dequeueReusableJTAppleMonthCell(withReuseIdentifier: "kkk", for: indexPath) as! MyCell
            f.dateFormat = "MMM"
            cell.monthLabel.text = f.string(from: date)
            return cell
        } else {
            let cell = calendar.dequeueReusableJTAppleMonthCell(withReuseIdentifier: "zzz", for: indexPath) as! YearHeaderCell
            f.dateFormat = "yyyy"
            cell.yearLabel.text = f.string(from: date)
            return cell
        }
    }
    
    
    
    func configureCalendar(_ calendar: JTACYearView) -> (configurationParameters: ConfigurationParameters, months: [Any]) {
        let df = DateFormatter()
        df.dateFormat = "yyyy MM dd"
        
        let sDate = df.date(from: "2019 01 01")!
        let eDate = df.date(from: "2050 05 31")!
        
        let configParams = ConfigurationParameters(startDate: sDate,
                                                   endDate: eDate,
                                                   numberOfRows: 6,
                                                   calendar: Calendar(identifier: .gregorian),
                                                   generateInDates: .forAllMonths,
                                                   generateOutDates: .tillEndOfGrid,
                                                   firstDayOfWeek: .sunday,
                                                   hasStrictBoundaries: true)
        
        // Get year data
        let dataSource = calendar.dataSourcefrom(configurationParameters: configParams)
        
        // Modify the data source to include a String every 12 data elements.
        // This string type will be used to add a header.
        var modifiedDataSource: [Any] = []
        for index in (0..<dataSource.count) {
            if index % 12 == 0 { modifiedDataSource.append("Year") }
            modifiedDataSource.append(dataSource[index])
        }

        return (configParams, modifiedDataSource)
    }
    
    
    // Drawing for individual item in a month cell.
    func calendar(_ calendar: JTACYearView, monthView: JTACCellMonthView, drawingFor rect: CGRect, with date: Date, dateOwner: DateOwner, monthIndex index: Int) {
        f.dateFormat = "d"
        let dateString = f.string(from: date)
        
        let paragraphStyle = NSMutableParagraphStyle()
        let font = UIFont(name: "HelveticaNeue", size: 8)!
        
        paragraphStyle.alignment = .center
        dateString.draw(in: rect, withAttributes: [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ])
    }
    
    func calendar(_ calendar: JTACYearView, sizeFor item: Any) -> CGSize {
        if item is Month {
            let width = (calendar.frame.width - 41 ) / 3
            let height = width
            return CGSize(width: width, height: height)
        } else {
            let width = calendar.frame.width - 41
            let height:CGFloat  = 20
            return CGSize(width: width, height: height)
        }
    }
    
    func calendar(_ calendar: JTACYearView, didSelectMonth month: Month, dateRange: (start: Date, end: Date), cell: JTACMonthCell?, indexPath: IndexPath) {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MMM YYYY"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd-MMM-YYYY"
        self.monthSelectLabel.text = "Selected Month \(formatter1.string(from: dateRange.start))\nWith Date Range:\n\(formatter2.string(from: dateRange.start)) to \(formatter2.string(from: dateRange.end))\nFor index Path: \(indexPath)"
    }
}


class MyCell: JTACMonthCell {
    @IBOutlet var monthLabel: UILabel!
}

class YearHeaderCell: JTACMonthCell {
    @IBOutlet var yearLabel: UILabel!
}
