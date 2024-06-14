# JTAppleCalendar Tutorials and Examples [V 7.1.7]

> [!CAUTION]
> This documentation comes from [this zipped version of the old docs site](https://github.com/patchthecode/JTAppleCalendar/issues/1397#issuecomment-2054113374) in the repo, and may be out of date with respect to the latest changes. Please submit an issue (or better yet a PR) to resolve any issues in the documentation

## Why use this library?

![alt text](./d708d542-b353-11e6-8119-fa36c11b66cb.gif)

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
   - [Configuring inDates/monthDates/outDates]()
   - [Regular selection](./regular-selection/Regular%20Selection.md)
   - [Handle device rotation](../common-elements/device-rotation/Handling%20Device%20Rotation.md)
4. [Scrolling modes]()
5. [Switch between month-view and week-view]()
6. [Headers](../headers/Headers.md)
7. [Range selection styles]()
8. [Events and loading information from a server]()
9. [How to add a week number column]()
