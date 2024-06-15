# Handling device rotation

Whenever the device orientation changes, you need to let the library know about it by calling this function

```swift
public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator, anchorDate: Date?)
```

Typically, developers should add it to the `viewWillTransition` delegate function of their ViewController SubClass.

Here is an example of the usage:

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    let visibleDates = calendarView.visibleDates()
    calendarView.viewWillTransition(to: .zero, with: coordinator, anchorDate: visibleDates.monthDates.first?.date)
}
```

The library needs to know what date should be focused on the screen when the orientation changes. In the above code, the first visible `monthDate` was captured and used as the anchor focus date.

When the orientation change completes, that month’s date will be focused on the screen.

## Next Steps

Learn more about [scrolling modes](../../scrolling-modes/Scrolling%20Modes.md)
