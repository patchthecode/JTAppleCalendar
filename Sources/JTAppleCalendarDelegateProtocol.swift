//
//  JTAppleCalendarDelegateProtocol.swift
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

protocol JTAppleCalendarDelegateProtocol: class {
    // Variables
    var allowsDateCellStretching: Bool {get set}
    var _cachedConfiguration: ConfigurationParameters! {get set}
    var calendarDataSource: JTAppleCalendarViewDataSource? {get set}
    var cellSize: CGFloat {get set}
    var anchorDate: Date? {get set}
    var isCalendarLayoutLoaded: Bool {get}
    var minimumInteritemSpacing: CGFloat  {get set}
    var minimumLineSpacing: CGFloat {get set}
    var monthInfo: [Month] {get set}
    var monthMap: [Int: Int] {get set}
    var scrollDirection: UICollectionView.ScrollDirection! {get set}
    var sectionInset: UIEdgeInsets {get set}
    var totalDays: Int {get}
    var requestedContentOffset: CGPoint {get}
    
    // Functions
    func pathsFromDates(_ dates: [Date]) -> [IndexPath]
    func sizeOfDecorationView(indexPath: IndexPath) -> CGRect
    func sizesForMonthSection() -> [AnyHashable:CGFloat]
    func targetPointForItemAt(indexPath: IndexPath) -> CGPoint?
}

extension JTAppleCalendarView: JTAppleCalendarDelegateProtocol { }
