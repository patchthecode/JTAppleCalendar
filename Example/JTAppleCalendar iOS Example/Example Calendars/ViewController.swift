//
//  ViewController.swift
//  JTAppleCalendar iOS Example
//
//  Created by JayT on 2016-08-10.
//
//

import JTAppleCalendar

class ViewController: UIViewController {

    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekViewStack: UIStackView!
    @IBOutlet var numbers: [UIButton]!
    @IBOutlet var outDates: [UIButton]!
    @IBOutlet var inDates: [UIButton]!
    
    var numberOfRows = 6
    let formatter = DateFormatter()
    var testCalendar = Calendar.current
    var generateInDates: InDateCellGeneration = .forAllMonths
    var generateOutDates: OutDateCellGeneration = .tillEndOfGrid
    var prePostVisibility: ((CellState, CellView?)->())?
    var hasStrictBoundaries = true
    let disabledColor = UIColor.lightGray
    let enabledColor = UIColor.blue
    var monthSize: MonthSize? = nil
    var prepostHiddenValue = false
    var outsideHeaderVisibilityIsOn = true
    var insideHeaderVisibilityIsOn = false
    
    var currentScrollModeIndex = 0
    let allScrollModes: [ScrollingMode] = [
        .none,
        .nonStopTo(customInterval: 374, withResistance: 0.5),
        .nonStopToCell(withResistance: 0.5),
        .nonStopToSection(withResistance: 0.5),
        .stopAtEach(customInterval: 374),
        .stopAtEachCalendarFrame,
        .stopAtEachSection
    ]
    
    @IBAction func changeScroll(_ sender: Any) {
        currentScrollModeIndex += 1
        if currentScrollModeIndex >= allScrollModes.count { currentScrollModeIndex = 0 }
        calendarView.scrollingMode = allScrollModes[currentScrollModeIndex]
        print("ScrollMode = \(allScrollModes[currentScrollModeIndex])")
        let sender = sender as! UIButton
        sender.setTitle("\(allScrollModes[currentScrollModeIndex])", for: .normal)
        
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
    
    @IBAction func toggleInsideHeaders(_ sender: UIButton) {
        if insideHeaderVisibilityIsOn {
            monthSize = nil
            sender.setTitle("Inside Header OFF", for: .normal)
        } else {
            monthSize = MonthSize(defaultSize: 50, months: [75: [.feb, .apr]])
            sender.setTitle("Inside Header ON", for: .normal)
        }
        insideHeaderVisibilityIsOn.toggle()
        calendarView.reloadData()
    }
    
    @IBAction func toggleOutsideHeaders(_ sender: UIButton) {
        if outsideHeaderVisibilityIsOn {
            monthLabel.isHidden = true
            weekViewStack.isHidden = true
            sender.setTitle("Outside Header ON", for: .normal)
        } else {
            monthLabel.isHidden = false
            weekViewStack.isHidden = false
            sender.setTitle("Outside Header OFF", for: .normal)
        }
        outsideHeaderVisibilityIsOn.toggle()
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
        if calendarView.cellSize == 0 { calendarView.cellSize = 54.0}
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
        if calendarView.scrollDirection == .horizontal {
            calendarView.scrollDirection = .vertical
//            calendarView.cellSize = 25
            sender.setTitle("Scrolling = Vertical", for: .normal)
        } else {
            calendarView.scrollDirection = .horizontal
//            calendarView.cellSize = 0
            sender.setTitle("Scrolling = Horizontal", for: .normal)
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
                              forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                              withReuseIdentifier: "PinkSectionHeaderView")
        
//        calendarView.allowsMultipleSelection = true
//        calendarView.allowsMultipleSelection = true
        
        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        setupScrollMode()
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
                let indexOfNewlySelectedDate = rangeSelectedDates.firstIndex(of: date)! + 1
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
        calendarView.reloadData(withAnchor: date)
    }

    @IBAction func reloadCalendar(_ sender: UIButton) {
        let date = Date()
        calendarView.reloadData(withAnchor: date)
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
    
    func handleCellConfiguration(cell: JTACDayCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        prePostVisibility?(cellState, cell as? CellView)
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTACDayCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = .white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = .black
            } else {
                myCustomCell.dayLabel.textColor = .gray
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let visibleDates = calendarView.visibleDates()
        calendarView.viewWillTransition(to: .zero, with: coordinator, anchorDate: visibleDates.monthDates.first?.date)
    }

    // Function to handle the calendar selection
    func handleCellSelection(view: JTACDayCell?, cellState: CellState) {
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
    
    func setupScrollMode() {
        currentScrollModeIndex = 6
        calendarView.scrollingMode = allScrollModes[currentScrollModeIndex]
    }
}

// MARK : JTAppleCalendarDelegate
extension ViewController: JTACMonthViewDelegate, JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = testCalendar.timeZone
        formatter.locale = testCalendar.locale
        
        
        let startDate = formatter.date(from: "2018 01 01")!
        let endDate = formatter.date(from: "2018 12 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: numberOfRows,
                                                 calendar: testCalendar,
                                                 generateInDates: generateInDates,
                                                 generateOutDates: generateOutDates,
                                                 firstDayOfWeek: .monday,
                                                 hasStrictBoundaries: hasStrictBoundaries)
        return parameters
    }
    
    func configureVisibleCell(myCustomCell: CellView, cellState: CellState, date: Date, indexPath: IndexPath) {
        myCustomCell.dayLabel.text = cellState.text
        if testCalendar.isDateInToday(date) {
            myCustomCell.backgroundColor = .red
        } else {
            myCustomCell.backgroundColor = .white
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
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // This function should have the same code as the cellForItemAt function
        let myCustomCell = cell as! CellView
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date, indexPath: indexPath)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date, indexPath: indexPath)
        return myCustomCell
    }

    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
//        print("After: \(calendar.contentOffset.y)")

    }
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let date = range.start
        let month = testCalendar.component(.month, from: date)
        formatter.dateFormat = "MMM"
        let header: JTACMonthReusableView
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
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return monthSize
    }
}
