# JTAppleCalendar Tutorials and Examples [V 7.1.7]

> [!CAUTION]
> This documentation comes from [this zipped version of the old docs site](https://github.com/patchthecode/JTAppleCalendar/issues/1397#issuecomment-2054113374) in the repo, and may be out of date with respect to the latest changes. Please submit an issue (or better yet a PR) to resolve any issues in the documentation

## [Version 8.0.0 migration guide](../migration-guide/v8%20Migration%20Guide.md)

## Why use this library?

![alt text](./image1.gif)

- **Total customization of all views** – This lib does not design anything. It only provides a layout (7 columns and 1-6 rows). Therefore any visual design of both cells and calendar is possible.
- **Horizontal or vertical mode** – Ability to switch from a vertical scrolling to horizontal scrolling calendar.
- **Range selection** – Select dates in a range.
- **Week/Month mode** – 7 columns (Sunday to Saturday). But you decide how many rows to display. Number of rows are limited to the range 1 to 6.
- **Custom first day of week** – First day of week does not have to be Sunday. You can pick any day.
- Headers – Ability to add headers of varying sizes for each month.

These are a fraction of many more features. Here are [calendar styles](https://github.com/patchthecode/JTAppleCalendar/issues/2) created by developers using this lib.

## Repetitive questions / delayed answers

Familiarity with the following non-calendar pointers, helps avoid repetitive questions and delayed answers.

- How to use UITableView or UICollectionView and understand how delegate functions work. Knowledge that cells are reused in these controls.
- Questions about this library asked on Github, will get a faster response than contacting me by email.
- Knowledge about the iOS Calendar() class and how time zones work in iOS to avoid questions such as [this one](https://github.com/patchthecode/JTAppleCalendar/issues/252) (2nd most repeated question)

Lets Begin!

1. [Installation](../installation/Installation.md)
2. [Build calendar from scratch](../build-calendar/Build%20A%20Calendar%20From%20Scratch.md)
3. [Common elements of every calendar](../common-elements/Common%20Elements.md)
   - [Configuring inDates/monthDates/outDates](../common-elements/configure-in-out-month-dates/Configuring%20inDates%20monthDates%20outDates.md)
   - [Regular selection](../common-elements//regular-selection/Regular%20Selection.md)
   - [Handle device rotation](../common-elements/device-rotation/Handling%20Device%20Rotation.md)
4. [Scrolling modes](../scrolling-modes/Scrolling%20Modes.md)
5. [Switch between month-view and week-view](../switch-month-to-week-view/Switch%20between%20month-view%20and%20week-view.md)
6. [Headers](../headers/Headers.md)
7. [Range selection styles](../range-selection-styles/Range%20selection%20styles.md)
8. [Events and loading information from a server](../adding-events/Adding%20Events.md)
9. [How to add a week number column](../implementing-week-numbers/Implementing%20week%20numbers.md)
