# JTAppleCalendar Version 8.0.0 Migration guide

Changes in version 8.0.0 are mainly that the function names are changed. why? We now support YearView. because of this, distiction has to be made between yearView and monthView.

**Important**: Because the names of some function have changed, if you forget to change their names you might notice things like “my functions are not being called”. If you are experiencing this, changes are you did not change the names.

## Renamed Delegate Function Names

```swift
func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool
func calendar(_ calendar: JTACMonthView, shouldDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool
func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath)
func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath)
func calendar(_ calendar: JTACMonthView, didHighlightDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath)
func calendar(_ calendar: JTACMonthView, didUnhighlightDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath)
func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo)
func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo)
func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView
func calendarDidScroll(_ calendar: JTACMonthView)
func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize?
func sizeOfDecorationView(indexPath: IndexPath) -> CGRect
func scrollDidEndDecelerating(for calendar: JTACMonthView)
```

## New Object Names

```swift
JTApplecalendarView           --&gt; JTACMonthView
JTAppleCalendarViewDelegate   --&gt; JTACMonthViewDelegate
JTAppleCalendarViewDataSource --&gt; JTACMonthViewDataSource
JTAppleDayCell                --&gt; JTACMonthCell
JTAppleCollectionReusableView --&gt; JTACMonthReusableView
```

## REPORTING / NOTES

If you used storyboards/xibs, remember to change the name of the classes in there as well. If we missed out any thing that caused the transition experience to be complicated, then open an issue and let us know right away. It will be fixed.
