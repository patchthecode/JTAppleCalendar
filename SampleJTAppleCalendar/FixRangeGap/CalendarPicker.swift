//
//  CalendarPicker.swift
//  SampleJTAppleCalendar
//
//  Created by Paul Addy on 29/3/23.
//  Copyright © 2023 OsTech. All rights reserved.
//

import JTAppleCalendar
import UIKit

public class CalendarPicker: UIStackView {
    // MARK: - Properties
    /// Callback when user selecting dates
    public var onSelectedDates: (([Date]) -> Void)?

    ///  Start date available to view in calendar. Default is 1 Jan 1970
    var startDate = Date.unixEpochDay

    ///  End date available to view in calendar. Default is infinity
    var endDate = Date.maxJTAppleCalendarDate

    /// Current showing month when start the calendar
    var showingMonth = Date()

    /// Enabled start dates to select. Depends on available dates specified in `startDate`
    var enabledStartDate: Date?

    /// Enabled end dates to select. Depends on available dates specified in `endDate`
    var enabledEndDate: Date?

    /// Specific disabled dates in array
    var disabledDates: [Date]?

    /// Selected dates to populate in calendar
    var selectedDates: [Date] = [] {
        didSet {
            calendar.reloadData()
            onSelectedDates?(selectedDates)
        }
    }

    /// To enable selecting date range
    var isSelectDateRangeEnabled = false
    var isDeselectingDateAllowed = true

    // MARK: - UI
    lazy var monthLabel: UILabel = {
        let view = UILabel()
        view.text = ""
        return view
     }()

    var iconSize: CGSize {
        CGSize(width: 24, height: 24)
    }
    lazy var daysRow: [UILabel] = {
        return Calendar(identifier: .gregorian).shortWeekdaySymbols.map {
            let view = UILabel()
            view.text = "\($0)"
            view.textColor = .black
            return view
        }
    }()

    lazy var weekDaysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        for day in daysRow {
            stackView.addArrangedSubview(day)
        }
        return stackView
     }()

//    lazy var rightChevronImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "chevronRightSmall24", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//        imageView.isUserInteractionEnabled = true
//        imageView.withSize(iconSize)
//        imageView.tintColor = .lightGray
//        imageView.addActionOnTap { [weak self] in
//            self?.navigateRight()
//        }
//        return imageView
//    }()
//
//    lazy var leftChevronImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "chevronLeftSmall24", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//        imageView.isUserInteractionEnabled = true
//        imageView.withSize(iconSize)
//        imageView.theme_tintColor = picker.color.icon.chevron.active
//        imageView.addActionOnTap { [weak self] in
//            self?.navigateLeft()
//        }
//        return imageView
//    }()

    lazy var monthControlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
//        stackView.addArrangedSubview(leftChevronImageView)
//        stackView.addArrangedSubview(rightChevronImageView)
        return stackView
    }()

    private var monthRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        return stackView
    }()

    public var calendarConfiguration: ConfigurationParameters {
        let parameters = ConfigurationParameters(
            startDate: startDate,
            endDate: endDate
        )
        return parameters
    }

    let dayCellID = "dayCellID"
    lazy var calendar: JTACMonthView = {
        let calendar = JTACMonthView(frame: CGRect.zero)
        calendar.translatesAutoresizingMaskIntoConstraints = false
//        calendar.theme_backgroundColor = picker.color.bg
//        calendar.backgroundColor = .white
        calendar.calendarDelegate = self
        calendar.calendarDataSource = self
        calendar.minimumInteritemSpacing = 0
        calendar.minimumLineSpacing = 0
        calendar.scrollingMode = .stopAtEachSection
        calendar.scrollDirection = .horizontal
        calendar.allowsMultipleSelection = true
        calendar.register(CalendarDayCellView.self, forCellWithReuseIdentifier: dayCellID)
        return calendar
    }()

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public init(
        startDate: Date = Date.unixEpochDay,
        endDate: Date = Date.maxJTAppleCalendarDate,
        isSelectDateRangeEnabled: Bool = true
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.isSelectDateRangeEnabled = isSelectDateRangeEnabled
        super.init(frame: .zero)
        setup()
    }
}

extension CalendarPicker {
    // MARK: - Setups
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical

//        monthLabel.numberOfLines = 1
//        monthRowStackView.addArrangedSubview(monthLabel)
//        monthRowStackView.addArrangedSubview(ADS.auto)
//        monthRowStackView.addArrangedSubview(monthControlStackView)
//        addArrangedSubview(monthRowStackView)
//        addArrangedSubview(ADSpacer(height: 16))
//        addArrangedSubview(weekDaysStackView)
//        addArrangedSubview(ADSpacer(height: 16))
//        addArrangedSubview(ADPageDividerSolidThin())
//        addArrangedSubview(ADSpacer(height: 16))
        addArrangedSubview(calendar)
        calendar.constrainHeight(220)
        updateDateEnable()
//        configureMonthView()
        calendar.scrollToDate(showingMonth, animateScroll: false)
    }
}

// MARK: - User Actions
extension CalendarPicker {
    @objc func navigateRight() {
        calendar.scrollToSegment(.next)
    }

    @objc func navigateLeft() {
        calendar.scrollToSegment(.previous)
    }
}

// MARK: - Helpers
extension CalendarPicker {
    func updateDateEnable() {
        startDate = Date()

//        switch displayRange {
//        case .currentMonth:
            endDate = Date().endOfMonth
//        case .threeMonthFromToday:
//            // showing 3 months including current month
//            endDate = Date().add(months: 2)
//        }
        calendar.reloadData()
    }

//    func configureMonthView(date: Date? = nil) {
//        let date = date ?? startDate
//        monthLabel.text = "\(date.monthName) \(date.yearCalendar)"
//        monthLabel.theme_textColor = picker.color.text.monthyear
//        monthLabel.textColor = .black
//        monthLabel.theme_textAttributes = picker.font.monthyearAttributedText

//        if Date.isMonthYearEqual(date1: date, date2: startDate) {
//            leftChevronImageView.isUserInteractionEnabled = false
//            leftChevronImageView.theme_tintColor = picker.color.icon.chevron.inactive
//        } else {
//            leftChevronImageView.isUserInteractionEnabled = true
//            leftChevronImageView.theme_tintColor = picker.color.icon.chevron.active
//        }
//
//        if Date.isMonthYearEqual(date1: date, date2: endDate) {
//            rightChevronImageView.isUserInteractionEnabled = false
//            rightChevronImageView.theme_tintColor = picker.color.icon.chevron.inactive
//        } else {
//            rightChevronImageView.isUserInteractionEnabled = true
//            rightChevronImageView.theme_tintColor = picker.color.icon.chevron.active
//        }
//    }

    /// Returns whether a date should be enabled or disabled
    /// - Parameter date: date to evaluate
    /// - Returns: true or false
    ///
    /// Note: dates whose values are stored in `disabledDates` and `disabledDays` have priority over those between
    /// `enabledStartDate` and `enabledEndDate`.
    func isDateEnabled(date: Date) -> Bool {
        if let disabledDates = disabledDates,
           disabledDates.contains(where: { $0.isSameDay(as: date) }) {
                return false
        }

        if enabledStartDate == nil && enabledEndDate == nil {
            return true
        }

        let startDate = enabledStartDate == nil ? Date.unixEpochDay : enabledStartDate!
        let endDate = enabledEndDate == nil ? Date.maxJTAppleCalendarDate : enabledEndDate!

        return date >= startDate && date <= endDate
    }

    func isDateSelected(date: Date) -> Bool {
        return selectedDates.contains { $0.isSameDay(as: date) }
    }

    func inRangeStatus(date: Date) -> CalendarDayCellView.InRangeStatus {
        if isSelectDateRangeEnabled,
           let startDate = selectedDates[safe: 0],
           let endDate = selectedDates[safe: 1] {
            if date.isSameDay(as: startDate) {
                return .startOfRange
            } else if date.isSameDay(as: endDate) {
                return .endOfRange
            } else if date > startDate && date < endDate {
                return .betweenRange
            }
        }

        return .none
    }
}

// MARK: - Additional API
extension CalendarPicker {
    /// Sets a range of enabled dates.
    /// - Parameters:
    ///   - start: start date
    ///   - end: end date
    func setEnabledDateRange(start: Date? = nil, end: Date? = nil) {
        enabledStartDate = start
        enabledEndDate = end
        calendar.reloadData()
    }

    /// Removes the date range specified by `setEnabledDateRange`.
    ///
    /// Note: This will result in the display of all dates from UNIX start to 127 years in the future, unless disabled dates have been specified.
    func resetEnabledDateRange() {
        enabledStartDate = nil
        enabledEndDate = nil
        calendar.reloadData()
    }

    /// Disables the dates specified by the array.
    /// - Parameter dates: array of dates
    ///
    /// Note:  Takes priority over dates specified by `setEnabledDateRange`.
    public func addDisabledDates(dates: [Date]) {
        disabledDates = dates
        calendar.reloadData()
    }

    /// Removes the dates specified by `addDisabledDates`.
    /// - Parameter dates: array of dates to remove
    func removeDisabledDates(dates: [Date]) {
        guard var disabledDates = disabledDates else {
            return
        }

        for date in dates {
            disabledDates.removeAll { disabledDate in
                disabledDate == date
            }
        }

        self.disabledDates = disabledDates
        calendar.reloadData()
    }

    /// Removes all dates specified by `addDisabledDates`.
    public func removeAllDisabledDates() {
        disabledDates = nil
        calendar.reloadData()
    }

    func scrollToDate(date: Date, animateScroll: Bool = true) {
        calendar.scrollToDate(date, animateScroll: animateScroll)
    }

    public func reset() {
        selectedDates = []
        disabledDates = []
//        configureMonthView()
        calendar.reloadData()
    }
}

