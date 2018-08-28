//
//  ViewController.swift
//  JTAppleCalendar iOS Example
//
//  Created by JayT on 2016-08-10.
//
//

import JTAppleCalendar

class ViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekViewStack: UIStackView!
    @IBOutlet var numbers: [UIButton]!
    @IBOutlet var headerss: [UIButton]!
    @IBOutlet var directions: [UIButton]!
    @IBOutlet var outDates: [UIButton]!
    @IBOutlet var inDates: [UIButton]!
    
    var numberOfRows = 6
    let formatter = DateFormatter()
    var testCalendar = Calendar.current
    var generateInDates: InDateCellGeneration = .forAllMonths
    var generateOutDates: OutDateCellGeneration = .tillEndOfGrid
    var prePostVisibility: ((CellState, CellView?)->())?
    var hasStrictBoundaries = true
    let firstDayOfWeek: DaysOfWeek = .monday
    let disabledColor = UIColor.lightGray
    let enabledColor = UIColor.blue
    let dateCellSize: CGFloat? = nil
    var monthSize: MonthSize? = nil
    var prepostHiddenValue = false
    
    let red = UIColor.red
    let white = UIColor.white
    let black = UIColor.black
    let gray = UIColor.gray
    let shade = UIColor(colorWithHexValue: 0x4E4E4E)
    
    @IBAction func scrollNone(_ sender: Any) {
        calendarView.scrollingMode = .none
    }
    
    @IBAction func scrollFixed(_ sender: Any) {
        calendarView.scrollingMode = .stopAtEachSection
    }
    @IBAction func showPrepost(_ sender: UIButton) {
        prePostVisibility = {state, cell in
            cell?.isHidden = false
        }
        calendarView.reloadData()
    }
    @IBAction func hidePrepost(_ sender: UIButton) {
        prePostVisibility = {state, cell in
            if state.dateBelongsTo == .thisMonth {
                cell?.isHidden = false
            } else {
                cell?.isHidden = true
            }
        }
        calendarView.reloadData()
    }
    
    @IBAction func showOutsideHeaders(_ sender: UIButton) {
        monthLabel.isHidden = false
        weekViewStack.isHidden = false
    }
    @IBAction func hideOutsideHeaders(_ sender: UIButton) {
        monthLabel.isHidden = true
        weekViewStack.isHidden = true
    }
    
    @IBAction func decreaseCellInset(_ sender: UIButton) {
        calendarView.minimumLineSpacing -= 0.5
        calendarView.minimumInteritemSpacing -= 0.5
        calendarView.reloadData()
    }
    
    @IBAction func increaseCellInset(_ sender: UIButton) {
        calendarView.minimumLineSpacing += 0.5
        calendarView.minimumInteritemSpacing += 0.5
        calendarView.reloadData()
    }
    
    
    @IBAction func decreaseItemSize(_ sender: UIButton) {
        calendarView.cellSize -= 1
        calendarView.reloadData()
    }
    
    @IBAction func increaseItemSize(_ sender: UIButton) {
        calendarView.cellSize += 1
        calendarView.reloadData()
    }

    
    @IBAction func changeToRow(_ sender: UIButton) {
        numberOfRows = Int(sender.title(for: .normal)!)!

        for aButton in numbers {
            aButton.tintColor = disabledColor
        }
        sender.tintColor = enabledColor
        calendarView.reloadData()
    }

    @IBAction func changeDirection(_ sender: UIButton) {
        for aButton in directions {
            aButton.tintColor = disabledColor
        }
        sender.tintColor = enabledColor

        if sender.title(for: .normal)! == "Horizontal" {
            calendarView.scrollDirection = .horizontal
            calendarView.cellSize = 0
        } else {
            calendarView.scrollDirection = .vertical
            calendarView.cellSize = 25
        }
        calendarView.reloadData()
    }
    
    @IBAction func toggleStrictBoundary(sender: UIButton) {
        hasStrictBoundaries = !hasStrictBoundaries
        if hasStrictBoundaries {
            sender.tintColor = enabledColor
        } else {
            sender.tintColor = disabledColor
        }
        calendarView.reloadData()
    }
    
    @IBAction func headers(_ sender: UIButton) {
        for aButton in headerss {
            aButton.tintColor = disabledColor
        }
        sender.tintColor = enabledColor

        if sender.title(for: .normal)! == "HeadersOn" {
            monthSize = MonthSize(defaultSize: 50, months: [75: [.feb, .apr]])
        } else {
            monthSize = nil
        }
        calendarView.reloadData()
    }

    @IBAction func outDateGeneration(_ sender: UIButton) {
        for aButton in outDates {
            aButton.tintColor = disabledColor
        }
        sender.tintColor = enabledColor

        switch sender.title(for: .normal)! {
        case "EOR":
            generateOutDates = .tillEndOfRow
        case "EOG":
            generateOutDates = .tillEndOfGrid
        case "OFF":
            generateOutDates = .off
        default:
            break
        }
        calendarView.reloadData()

    }

    @IBAction func inDateGeneration(_ sender: UIButton) {
        for aButton in inDates {
            aButton.tintColor = disabledColor
        }
        sender.tintColor = enabledColor

        switch sender.title(for: .normal)! {
            case "First":
                generateInDates = .forFirstMonthOnly
            case "All":
                generateInDates = .forAllMonths
            case "Off":
                generateInDates = .off
        default:
            break
        }

        calendarView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.register(UINib(nibName: "PinkSectionHeaderView", bundle: Bundle.main),
                              forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                              withReuseIdentifier: "PinkSectionHeaderView")
        
        
        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
    var rangeSelectedDates: [Date] = []
    func didStartRangeSelecting(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: gesture.view!)
        rangeSelectedDates = calendarView.selectedDates
        if let cellState = calendarView.cellStatus(at: point) {
            let date = cellState.date
            if !calendarView.selectedDates.contains(date) {
                let dateRange = calendarView.generateDateRange(from: calendarView.selectedDates.first ?? date, to: date)
                for aDate in dateRange {
                    if !rangeSelectedDates.contains(aDate) {
                        rangeSelectedDates.append(aDate)
                    }
                }
                calendarView.selectDates(from: rangeSelectedDates.first!, to: date, keepSelectionIfMultiSelectionAllowed: true)
            } else {
                let indexOfNewlySelectedDate = rangeSelectedDates.index(of: date)! + 1
                let lastIndex = rangeSelectedDates.endIndex
                let followingDay = testCalendar.date(byAdding: .day, value: 1, to: date)!
                calendarView.selectDates(from: followingDay, to: rangeSelectedDates.last!, keepSelectionIfMultiSelectionAllowed: false)
                rangeSelectedDates.removeSubrange(indexOfNewlySelectedDate..<lastIndex)
            }
        }
        
        if gesture.state == .ended {
            rangeSelectedDates.removeAll()
        }
    }
    
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func printSelectedDates() {
        print("\nSelected dates --->")
        for date in calendarView.selectedDates {
            print(formatter.string(from: date))
        }
    }

    @IBAction func resize(_ sender: UIButton) {
        
        
        calendarView.frame = CGRect(
            x: calendarView.frame.origin.x,
            y: calendarView.frame.origin.y,
            width: calendarView.frame.width,
            height: calendarView.frame.height - 50
        )
        
        let date = calendarView.visibleDates().monthDates.first!.date
        calendarView.reloadData(withanchor: date)
    }

    @IBAction func reloadCalendar(_ sender: UIButton) {
        let date = Date()
        calendarView.reloadData(withanchor: date)
    }

    @IBAction func next(_ sender: UIButton) {
        self.calendarView.scrollToSegment(.next)
    }

    @IBAction func previous(_ sender: UIButton) {
        self.calendarView.scrollToSegment(.previous)
    }

    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = testCalendar.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = testCalendar.component(.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }
    
    func handleCellConfiguration(cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        prePostVisibility?(cellState, cell as? CellView)
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = black
            } else {
                myCustomCell.dayLabel.textColor = gray
            }
        }
    }
    
    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView else {return }
//        switch cellState.selectedPosition() {
//        case .full:
//            myCustomCell.backgroundColor = .green
//        case .left:
//            myCustomCell.backgroundColor = .yellow
//        case .right:
//            myCustomCell.backgroundColor = .red
//        case .middle:
//            myCustomCell.backgroundColor = .blue
//        case .none:
//            myCustomCell.backgroundColor = nil
//        }
//        
        if cellState.isSelected {
            myCustomCell.selectedView.layer.cornerRadius =  13
            myCustomCell.selectedView.isHidden = false
        } else {
            myCustomCell.selectedView.isHidden = true
        }
    }
    
    
    @IBAction func decreaseSectionInset(_ sender: UIButton) {
        
        calendarView.sectionInset.bottom -= 3
        calendarView.sectionInset.top -= 3
        calendarView.sectionInset.left -= 3
        calendarView.sectionInset.right -= 3
        
        calendarView.reloadData()
    }
    
    @IBAction func increaseSectionInset(_ sender: UIButton) {
                calendarView.sectionInset.bottom += 3
                calendarView.sectionInset.top += 3
        calendarView.sectionInset.left += 3
        calendarView.sectionInset.right += 3
        calendarView.reloadData()
    }
}

// MARK : JTAppleCalendarDelegate
extension ViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = testCalendar.timeZone
        formatter.locale = testCalendar.locale
        
        
        let startDate = formatter.date(from: "2018 01 01")!
        let endDate = formatter.date(from: "2019 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: numberOfRows,
                                                 calendar: testCalendar,
                                                 generateInDates: generateInDates,
                                                 generateOutDates: generateOutDates,
                                                 firstDayOfWeek: firstDayOfWeek,
                                                 hasStrictBoundaries: hasStrictBoundaries)
        return parameters
    }
    
    func configureVisibleCell(myCustomCell: CellView, cellState: CellState, date: Date) {
        myCustomCell.dayLabel.text = cellState.text
        if testCalendar.isDateInToday(date) {
            myCustomCell.backgroundColor = red
        } else {
            myCustomCell.backgroundColor = white
        }
        
        handleCellConfiguration(cell: myCustomCell, cellState: cellState)
        
        
        if cellState.text == "1" {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: date)
            myCustomCell.monthLabel.text = "\(month) \(cellState.text)"
        } else {
            myCustomCell.monthLabel.text = ""
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // This function should have the same code as the cellForItemAt function
        let myCustomCell = cell as! CellView
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
        return myCustomCell
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let date = range.start
        let month = testCalendar.component(.month, from: date)
        
        let header: JTAppleCollectionReusableView
        if month % 2 > 0 {
            header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "WhiteSectionHeaderView", for: indexPath)
            (header as! WhiteSectionHeaderView).title.text = formatter.string(from: date)
        } else {
            header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "PinkSectionHeaderView", for: indexPath)
            (header as! PinkSectionHeaderView).title.text = formatter.string(from: date)
        }
        return header
    }
    
    func sizeOfDecorationView(indexPath: IndexPath) -> CGRect {
        let stride = calendarView.frame.width * CGFloat(indexPath.section)
        return CGRect(x: stride + 5, y: 5, width: calendarView.frame.width - 10, height: calendarView.frame.height - 10)
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return monthSize
    }
}
