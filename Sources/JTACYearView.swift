//
//  JTAppleCalendarYearView.swift
//
//  Copyright (c) 2016-2017 JTAppleCalendar (https://github.com/patchthecode/JTAppleCalendar)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

open class JTACYearView: UICollectionView {
    var configurationParameters = ConfigurationParameters(startDate: Date(), endDate: Date())
    var monthData: [Any] = []
    
    
    /// The object that acts as the delegate of the calendar year view.
    weak open var calendarDelegate: JTACYearViewDelegate?
    weak open var calendarDataSource: JTACYearViewDataSource? {
        didSet { setupYearViewCalendar() }
    }
    
    /// Workaround for Xcode bug that prevents you from connecting the delegate in the storyboard.
    /// Remove this extra property once Xcode gets fixed.
    @IBOutlet public var ibCalendarDelegate: AnyObject? {
        get { return calendarDelegate }
        set { calendarDelegate = newValue as? JTACYearViewDelegate }
    }
    
    /// Workaround for Xcode bug that prevents you from connecting the delegate in the storyboard.
    /// Remove this extra property once Xcode gets fixed.
    @IBOutlet public var ibCalendarDataSource: AnyObject? {
        get { return calendarDataSource }
        set { calendarDataSource = newValue as? JTACYearViewDataSource }
    }
    
    open func dataSourcefrom(configurationParameters: ConfigurationParameters) -> [Any] {
        return JTAppleDateConfigGenerator.shared.setupMonthInfoDataForStartAndEndDate(configurationParameters).months
    }
    
    func setupYearViewCalendar() {
        guard let validConfig = calendarDataSource?.configureCalendar(self) else {
            print("Invalid datasource")
            return;
        }
        
        configurationParameters = validConfig.configurationParameters
        monthData               = validConfig.months
        dataSource = self
        delegate = self
    }
    
}

extension JTACYearView: JTACCellMonthViewDelegate {
    public func monthView(_ monthView: JTACCellMonthView, drawingFor segmentRect: CGRect, with date: Date, dateOwner: DateOwner, monthIndex: Int) {
        calendarDelegate?.calendar(self, monthView: monthView, drawingFor: segmentRect, with: date, dateOwner: dateOwner, monthIndex: monthIndex)
    }
}
