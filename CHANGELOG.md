# Change Log
All notable changes to this project will be documented in this file.
`JTAppleCalendar` adheres to [Semantic Versioning](http://semver.org/).

#### 7.x Releases
- `7.1.0` Releases - [7.1.0](#710)|[7.1.1](#711)|[7.1.2](#712)|[7.1.3](#713)|[7.1.4](#714)|[7.1.5](#715)
- `7.0.0` Releases - [7.0.0](#700)|[7.0.1](#701)|[7.0.2](#702)|[7.0.3](#703)|[7.0.4](#704)|[7.0.5](#705)|[7.0.6](#706)

#### 6.x Releases
- `6.1.0` Releases - [6.1.0](#610)|[6.1.1](#611)|[6.1.2](#612)|[6.1.3](#613)|[6.1.4](#614)|[6.1.5](#615)|[6.1.6](#616)
- `6.0.0` Releases - [6.0.0](#600)|[6.0.1](#601)|[6.0.2](#602)|[6.0.3](#603)|[6.0.4](#604)|[6.0.5](#605)
- `6.0.0` Betas - [6.0.0-beta.1](#600-beta1)

#### 5.x Releases
- `5.0.0` Releases - [5.0.0](#500)|[5.0.1](#501)

#### 4.x Releases
- `4.1.0` Releases - [4.1.0](#410)|[4.1.1](#411)|[4.1.2](#412)|[4.1.3](#413)|[4.1.4](#414)
- `4.0.0` Releases - [4.0.0](#400)|[4.0.1](#401)|[4.0.2](#402)|[4.0.3](#403)

#### 3.x Releases
- `3.0.0` Releases - [3.0.0](#300)|[3.0.1](#301)

#### 2.x Releases
- `2.1.0` Releases - [2.1.0](#210)|[2.1.1](#211)|[2.1.2](#212)
- `2.0.0` Releases - [2.0.0](#200)|[2.0.1](#201)|[2.0.2](#202)|[2.0.3](#203)

#### 1.x Releases
- `1.1.x` Releases - [1.1.0](#110)| [1.1.1](#111)
- `1.0.x` Releases - [1.0.0](#100)

---
## [7.1.5](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.1.5)
- Fixed inset bug #419
- Fixed unowned Crash #624

- Updated by [JayT](https://github.com/patchthecode).
## [7.1.4](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.1.4)
- Fixed [programatic selection bug](https://github.com/patchthecode/JTAppleCalendar/commit/de5f0023fb6b157bddb2afa9637c7be0a1bbc636)
- Updated by [JayT](https://github.com/patchthecode).

## [7.1.3](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.1.3)
- Fixed rounding error
- Updated by [JayT](https://github.com/patchthecode).

## [7.1.2](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.1.2)
- Fixed rounding error - https://github.com/patchthecode/JTAppleCalendar/commit/c4059147f03695b66a044c16cc4f0ec67d87eae2
    - Updated by [JayT](https://github.com/patchthecode).

## [7.1.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.1.1)
- Fixed errors - https://github.com/patchthecode/JTAppleCalendar/issues/598

## [7.1.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.1.0)
- Fixed errors.
- Made library compatible with iOS8
- CellState now informs if library made programatic vs user selected tap on cell

## [7.0.6](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.0.6)
- [bug fix - accidentaly introduced in 7.0.5](https://github.com/patchthecode/JTAppleCalendar/commit/7f60c8c5b2265954ad0041ac4f150c6f4862cdb7)
- Other code cleanup
  - Updated by [JayT](https://github.com/patchthecode).
  - Updated by [mayurdzk](https://github.com/mayurdzk).
  - Updated by [mgurreta](https://github.com/mgurreta).

## [7.0.5](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.0.5)
- [bug fix](https://github.com/patchthecode/JTAppleCalendar/commit/bcbb2bc5696cb2f15a6e87e1023c3a9cdf3dfdff)
- [added anchor dates on reload](https://github.com/patchthecode/JTAppleCalendar/commit/b81158dfd7600e1d31143be4fbfba32af2187253)
   - Sometimes on reload you do not want to see scrolling. Anchor dates solved that problem.
- [Fixed double reloading of calendar](https://github.com/patchthecode/JTAppleCalendar/commit/05c6f518de9484d19faba2ae2f7fba2ffb8e9cba)
- [Fixed crash when resizing from zero height/width](https://github.com/patchthecode/JTAppleCalendar/commit/765d919bb91fa3817d79d78f735bee0b720f3ba3)
- [Added function to get month data](https://github.com/patchthecode/JTAppleCalendar/commit/502d53d7a815f93e099bb2b81b4c4b6e125b26bb)

## [7.0.4](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.0.4)
- [Function signature change to fix issue on shouldSelect/shouldDeselect function](https://github.com/patchthecode/JTAppleCalendar/commit/64b2bd1aa8ecab97c8a2bc92020724e97702887a)
- Reverted unavailability of isSelected on date cells.

## [7.0.3](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.0.3)
- [Changed order in which delegates are called](https://github.com/patchthecode/JTAppleCalendar/issues/431)
- [Fixed recursive loop error](https://github.com/patchthecode/JTAppleCalendar/commit/e95ec9806ef932a619329b3f40062ad125b4a17e)
- [Potential crash fix. Incorrectly used statdard function instead of custom](https://github.com/patchthecode/JTAppleCalendar/commit/3cbfab2382ccb7168a5c22e0081504f43d0d76e6)
- [ShouldSelect should be called on programatic selection](https://github.com/patchthecode/JTAppleCalendar/commit/4f528d17842848bf3cca4b80ce2fb89958caf614)

## [7.0.2](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.0.2)
- [Fixed visible scrolling issue](https://github.com/patchthecode/JTAppleCalendar/issues/263)
- Added check if dev forcefully calls layoutIfNeeded(). Layout should be re-created.

## [7.0.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.0.1)
- Quickfix for Charthage users. Correct header file was included. 

## [7.0.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/7.0.0)
- Massive changes and minor bug fixes 
   - JTAppleCalendar is now a UICollectionView subclass and can be designed on interface builder.
   - Months sections distance is now configurable
   - [Scroll to date can now be done with an offset](https://github.com/patchthecode/JTAppleCalendar/issues/332)
   - [Decoration-views added](https://github.com/patchthecode/JTAppleCalendar/issues/296). You can now design the calendar with whatever view you choose
   - Performance load time of dates has been decreased
   - [Visible fixed](https://github.com/patchthecode/JTAppleCalendar/issues/263)
   
## [6.1.6](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.1.6)
- Fixed - [Memory leak](https://github.com/patchthecode/JTAppleCalendar/issues/333)
- Fixed - [Over scrolling in vertical mode when scrolled to last date](https://github.com/patchthecode/JTAppleCalendar/issues/344)

## [6.1.5](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.1.5)
- Fixed - [Crash on reloading items](https://github.com/patchthecode/JTAppleCalendar/issues/327)

## [6.1.4](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.1.4)
- Fixed - [Crash in speific regions](https://github.com/patchthecode/JTAppleCalendar/issues/323)
- Fixed - [Scroll to date delegate not called. New introduced bug](https://github.com/patchthecode/JTAppleCalendar/issues/325)

## [6.1.3](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.1.3)
- Fixed - [Incorrect selected position](https://github.com/patchthecode/JTAppleCalendar/issues/280) when using range selection.
- Behavior change - Changing the frame size no longer automatically reloads the calendar. This should explicitly be done by the developer.
- Fixed error - [Reloading cells asynchronously](https://github.com/patchthecode/JTAppleCalendar/issues/304) which caused two errors [here](https://github.com/patchthecode/JTAppleCalendar/issues/304) and [here](https://github.com/patchthecode/JTAppleCalendar/issues/277) - JayT
- Fixed error - [Last saved offset fixed programatically](https://github.com/patchthecode/JTAppleCalendar/pull/276) - by [KyleConway](https://github.com/KyleConway)
- Fixed error - [visibleDates() function should exclude headers](https://github.com/patchthecode/JTAppleCalendar/pull/278) - by [KyleConway](https://github.com/KyleConway)

## [6.1.2](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.1.2)
- Fixed error - deselect all dates should work as expected
- Fixed error - Introduced in last version. DidScroll delegate was not being called.
- Fixed error - Vertical calendar was not being displayed correctly in some configurations.
  - Updated by [JayT](https://github.com/patchthecode).

## [6.1.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.1.1)
- Documentation updates

## [6.1.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.1.0)
- [Fixed error - triggerScrollToDateDelegate was not called](https://github.com/patchthecode/JTAppleCalendar/issues/235)
- [Fixed error introduced in last version - scroll To date broke](https://github.com/patchthecode/JTAppleCalendar/issues/223)
- Performance updates
- Behavior change - [Library will now honour time zones based on Calenda() instance](https://github.com/patchthecode/JTAppleCalendar/issues/222)
  - Updated by [JayT](https://github.com/patchthecode).

## [6.0.5](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.0.5)
- [Floating point error fix](https://github.com/patchthecode/JTAppleCalendar/issues/211)
  - Updated by [JayT](https://github.com/patchthecode).

## [6.0.4](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.0.4)
- [Fixed wrong date bug](https://github.com/patchthecode/JTAppleCalendar/commit/1689586c70e2fbd9785794c4fc8c5f094403e98f)
  - Updated by [JayT](https://github.com/patchthecode).

## [6.0.3](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.0.3)
- [Fixed wrong date bug](https://github.com/patchthecode/JTAppleCalendar/issues/210)
- Fixed Scrolling issues with new segment code
  - Updated by [JayT](https://github.com/patchthecode).

## [6.0.2](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.0.2)
- Fixed error: [Cells are not updated properly because of pre-fetching](https://github.com/patchthecode/JTAppleCalendar/issues/196)
- New Feature: Gesture functionality added
- Fixed error: [Fix for vertical direction](https://github.com/patchthecode/JTAppleCalendar/commit/4d48c594e00864dbe470dc64dbfd2e8790dbe783)
- Fixed error: [Vertical cell size](https://github.com/patchthecode/JTAppleCalendar/commit/8e85b784bfe5ff8669157f42aee17aaee99a9429)
- Fixed error: [Reload data completionhandler does not work when view is first loaded](https://github.com/patchthecode/JTAppleCalendar/commit/da0a0ad9b22b6e50fa2feec644afaa6902ad4a5e)
  - Updated by [JayT](https://github.com/patchthecode).

## [6.0.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.0.1)
- Fixed error: [Left over artifacts](https://github.com/patchthecode/JTAppleCalendar/commit/f5be1e1c281cb08337ede276403311b3ee4a4e9f)
- Fixed error: [Potential infinite loop on scrollViewDidEnd](https://github.com/patchthecode/JTAppleCalendar/commit/a115ff9301118fd93ab8ed960ba33ebeb28b8f7b)
- Update: [Changed variable names for consistency](https://github.com/patchthecode/JTAppleCalendar/commit/3eca0fddc79a6425c146b65aabd2ff31b0c0d05d)
- Update: [Added functionality to flip calendar horizontally for ethnic calendars](https://github.com/patchthecode/JTAppleCalendar/commit/a991b898a2ce5bc3a678bcf0b43a8e381e56a840)
- Update: `ConfigureCaneldar` function signature has changed. 
- Fixed error: [XCode 8.1 has a bug](https://github.com/patchthecode/JTAppleCalendar/commit/97363897006877b62ebfb357cb98160a1b5b291b). So a work around was implemented
  - Updated by [JayT](https://github.com/patchthecode).

## [6.0.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.0.0)
- Added functionality to get dateCell by CGPoint
  - Updated by [JayT](https://github.com/patchthecode).

## [6.0.0-beta.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/6.0.0-beta.1)
- Made function names more standardised
- Added ability enable/disable in-dates/out-dates generation
- Added ability to choose buldle for xib files
  - Updated by [JayT](https://github.com/patchthecode).

## [5.0.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/5.0.1)
- Bug Fix: [Crash on negative scroll in vertical mode](https://github.com/patchthecode/JTAppleCalendar/issues/115)
  - Updated by [JayT](https://github.com/patchthecode).

## [5.0.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/5.0.0)
- Bug Fix: [Double calling of delegate method on finger lift](https://github.com/patchthecode/JTAppleCalendar/issues/102)
- Bug Fix: [Delegate call fixed when user scrolls to top using status bar](https://github.com/patchthecode/JTAppleCalendar/issues/89)
- Bug Fix: [Crash when calenader switched to single row](https://github.com/patchthecode/JTAppleCalendar/issues/111)
- Update: Added range selection
- Update: [Deprecations](https://github.com/patchthecode/JTAppleCalendar/wiki/Message-to-testers-working-on-master-branch)
- Update: JTApplecalendar now works for tvOS
  - Updated by [JayT](https://github.com/patchthecode).

## [4.1.4](https://github.com/patchthecode/JTAppleCalendar/releases/tag/4.1.4)
- Bug Fixes: [Scroll to section bug introduced](https://github.com/patchthecode/JTAppleCalendar/issues/96)
  - Updated by [JayT](https://github.com/patchthecode).

## [4.1.3](https://github.com/patchthecode/JTAppleCalendar/releases/tag/4.1.3)
- Added missing functionality: To give dev a chance to clean up the cell before being reused.
- Added missing functionality: Headers can now be registered using classes.
- Bug Fixes: [Crash when using multiplel instance of JTAppleCalendar](https://github.com/patchthecode/JTAppleCalendar/issues/75)
  - Updated by [JayT](https://github.com/patchthecode).

## [4.1.2](https://github.com/patchthecode/JTAppleCalendar/releases/tag/4.1.1)
- Fixed issue: removed forced unwrapping of date on deselection. [Caused crash](https://github.com/patchthecode/JTAppleCalendar/issues/69)
- Fixed issue: on reloading index paths, removed dupicates. Caused visual glitch.
  - Updated by [JayT](https://github.com/patchthecode).

## [4.1.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/4.1.1)
- Fixed issue: Various bug fixes and enhancements
   - [Days of the week can now be used in calculations]()
   - [Cells cannot be decelected sometimes](https://github.com/patchthecode/JTAppleCalendar/issues/67)
   - [Bug on multiple selection](https://github.com/patchthecode/JTAppleCalendar/issues/64)
   - [Bug when 2 months are displayed](https://github.com/patchthecode/JTAppleCalendar/issues/63)
   - performance fix
- Added functoin to generate dates and select date range
  - Updated by [JayT](https://github.com/patchthecode).

## [4.1.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/4.1.0)
- Feature Added: Devs can now configure the width and height of a dateCell.
- Fixed issue: Synchonization issues on calendar start
- Fixed issue: Fixed layout [Bug](https://github.com/patchthecode/JTAppleCalendar/issues/57)
- performance fixes
  - Updated by [JayT](https://github.com/patchthecode).

## [4.0.3](https://github.com/patchthecode/JTAppleCalendar/releases/tag/4.0.3)
- Fixed issue: Performance fixes - Library should work smooth on an iPhone 4s
- Fixed issue: Scroll to segments were not calling completion handlers
- Fixed issue: Added fix for device orientation
- Added missing functionality: Devs can now register cells by type
  - Updated by [JayT](https://github.com/patchthecode).
  - Fix added by: [Baptiste Sansierra](https://github.com/patchthecode/JTAppleCalendar/pull/48)
  - Functionality added by: [Encero](https://github.com/patchthecode/JTAppleCalendar/pull/49)

## [4.0.2](https://github.com/patchthecode/JTAppleCalendar/releases/tag/4.0.2)
- Fixed issue: Layout issue in 4.0.1. 
  - Updated by [JayT](https://github.com/patchthecode).

## [4.0.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/4.0.1)
- Fixed issue: Performance fixes 
- Fixed issue: Layout issues
  - Updated by [JayT](https://github.com/patchthecode).

## [4.0.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/4.0.0)
- Fixed issue: Performance fixes 
- Fixed issue: Changed way numberOfRows is configured. New way solves concurrency issues
  - Updated by [JayT](https://github.com/patchthecode).

## [3.0.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/3.0.1)
- Fixed issue: Cell Inset was borken with 3.0.0 release
- Fixed issue: canSelectDate always returned true. 
  - Updated by [JayT](https://github.com/patchthecode).
  
## [3.0.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/3.0.0)
- Fixed: Issue [#20](https://github.com/patchthecode/JTAppleCalendar/issues/20). Layout should be set to needsUpdate when firstDayOfWeek changes
- Update: Issue [#19](https://github.com/patchthecode/JTAppleCalendar/issues/19). DidScroll delegate will now only get called when user scolls. This makes clear system actions vs user actions.
- Fixed: Issue [#18](https://github.com/patchthecode/JTAppleCalendar/issues/18). Selecting out-dates now also select their date counterparts.
- Update: Issue [#16](https://github.com/patchthecode/JTAppleCalendar/issues/16). Headers are now added to the project.
  - Updated by [JayT](https://github.com/patchthecode).

## [2.1.2](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.1.2)
- Fixed: When selecting date with delegates disabled, calendar shifted to month offset. This was due to the newly added smooth scrolling feature
- Update: The CellState for a date now returns more information. It now returns (added to its previous info) a date and a day.
- Update: New function added so user can query the visible dateCells on the screen: cellStatusForDateAtRow(_: Int, column: Int)
- Update: With paging disbled, the scrolling now snaps to day
  - Updated by [JayT](https://github.com/patchthecode).

## [2.1.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.1.1)
- Crash on using NSDate() without a formatter for date ranges [Issue 11](https://github.com/patchthecode/JTAppleCalendar/issues/11)
  - Updated by [JayT](https://github.com/patchthecode).

## [2.1.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.1.0)
- Calendar paging is now an option
- Scroll to date method will now scroll to a date if paging is set to off. [Issue 10](https://github.com/patchthecode/JTAppleCalendar/issues/10)
  - Updated by [JayT](https://github.com/patchthecode).


## [2.0.3](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.0.3)
- Fixed visual bug. Now there should be no flickering when scrolling dates.
- Updated sample code 
  - Updated by [JayT](https://github.com/patchthecode).


## [2.0.2](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.0.2)
- Added functionality to not trigger delegates on selecting dates
- Updated sample code 
  - Updated by [JayT](https://github.com/patchthecode).


## [2.0.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.0.0)
- Added function to handle date selection in Arrays
  - Updated by [JayT](https://github.com/patchthecode).


## [2.0.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/2.0.0)
Released on 2016-04-5. All issues associated with this milestone can be found using this 
[filter](https://github.com/patchthecode/JTAppleCalendar/milestones/Obvious%20things%20that%20were%20missed%20in%20Initial%20Coding)

#### Updated
- fixed date selection method. 
- made didSelectDate function return an optional object. The value can be nil if the selected date is off the screen.
  - Updated by [JayT](https://github.com/patchthecode).


## [1.1.1](https://github.com/patchthecode/JTAppleCalendar/releases/tag/1.1.1)
Released on 2016-03-20.

#### Updated
- Updated packages
- Updated by [JayT](https://github.com/patchthecode).


## [1.1.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/1.1.0)
Released on 2016-03-28.

#### Updated
- Added functionality to query current date section
- Calendar-view now reloads on datasource change
  - Updated by [JayT](https://github.com/patchthecode).


## [1.0.0](https://github.com/patchthecode/JTAppleCalendar/releases/tag/1.0.0)
Released on 2016-03-27.

#### Added
- Initial release of JTAppleCalendar.
  - Added by [JayT](https://github.com/patchthecode).
