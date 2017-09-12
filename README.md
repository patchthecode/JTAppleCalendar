[![jtapplecalendarnewlogo](https://cloud.githubusercontent.com/assets/2439146/20656424/a1c98c8e-b4e1-11e6-9833-5fa6430f5a8c.png)](https://github.com/patchthecode/JTAppleCalendar)

[![Tutorial](https://img.shields.io/badge/Tutorials-patchthecode.github.io-blue.svg)](https://patchthecode.github.io/) [![Version](https://img.shields.io/cocoapods/v/JTAppleCalendar.svg?style=flat)](http://cocoapods.org/pods/JTAppleCalendar) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Platform](https://img.shields.io/cocoapods/p/JTAppleCalendar.svg?style=flat)](http://cocoapods.org/pods/JTAppleCalendar) [![License](https://img.shields.io/cocoapods/l/JTAppleCalendar.svg?style=flat)](http://cocoapods.org/pods/JTAppleCalendar) [![](https://www.paypalobjects.com/webstatic/en_US/btn/btn_donate_74x21.png)](https://github.com/patchthecode/JTAppleCalendar/wiki/Support)

#### Q: How will my calendar dateCells look with this library?
**A**: However you want it to look.
### Tutorials now @ [patchthecode.github.io](https://patchthecode.github.io/)

<p align="center">
   <a href="https://github.com/patchthecode/JTAppleCalendar/issues/2">
      <img src="https://cloud.githubusercontent.com/assets/2439146/20638185/d708d542-b353-11e6-8119-fa36c11b66cb.gif" height="450">
   </a>
</p>
<p align="center">  
   <a href="https://github.com/patchthecode/JTAppleCalendar/issues/2">More Images</a>
</p>


## Features
---

- [x] Range selection - select dates in a range. The design is entirely up to you.
- [x] Boundary dates - limit the calendar date range
- [x] Week/month mode - show 1 row of weekdays. Or 2, 3 or 6
- [x] Custom cells - make your day-cells look however you want, with any functionality you want
- [x] Custom calendar view - make your calendar look however you want, with what ever functionality you want
- [x] First Day of week - pick anyday to be first day of the week
- [x] Horizontal or vertical mode
- [x] Ability to add month headers in varying sizes/styles of your liking
- [x] Ability to scroll to any month by simply using the date
- [x] Ability to design your calendar [however you want.](https://github.com/patchthecode/JTAppleCalendar/issues/2) You want it, you build it
- [x] [Complete Documentation](http://cocoadocs.org/docsets/JTAppleCalendar)


[Installation](#installation)

Tutorials
  
  **1. Building a Calendar from scratch**
   
   [<img width="300" alt="screen shot 2017-04-07 at 1 10 00 am" src="https://cloud.githubusercontent.com/assets/2439146/24791476/10ae6602-1b2f-11e7-9d2b-038b007090ab.png">](https://www.youtube.com/watch?v=zOphH-h-qCs)
   
   **2. Designing the Calendar [Part1]**
   
   [<img width="300" alt="screen shot 2017-04-09 at 5 16 16 pm" src="https://cloud.githubusercontent.com/assets/2439146/24842167/78a730a2-1d48-11e7-9c63-304491283ce6.png">](https://www.youtube.com/watch?v=Qd_Gc67xzlw)

   **3. Mastering Calendar layouts**
   
   [<img width="300" alt="screen shot 2017-04-16 at 1 02 30 am" src="https://cloud.githubusercontent.com/assets/2439146/25069787/82c4c886-2240-11e7-94be-324cde5bed4a.png">](https://www.youtube.com/watch?v=1Sta3aEo9E4)

   **4. Common Questions #1**
   
   [<img width="300" alt="screen shot 2017-04-16 at 1 02 30 am" src="https://user-images.githubusercontent.com/2439146/28244395-068cdc62-699f-11e7-9c31-5630745aa130.png">](https://www.youtube.com/watch?v=CQNotydm58s)
   

## Installation
___

### 1. Installing via CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build JTApplecalendar.

To integrate JTAppleCalendar into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'JTAppleCalendar', '~> 7.0'
end
```

Then, run the following command:

```bash
$ pod install
```

**Completed!**

New to Cocoapods? Did the steps above fail? Then read on.

If you're new to CocoaPods, simply search how to integrate Cocoapods into your project. Trust me that 5-7 minutes of research will bring you much benefit. CocoaPods one of the top dependency manager for integrating 3rd party frameworks into your project. But in a nut-shell, here is how I did my installation with a sample project called **test**

1. Install Cocoapods.
2. Create a new xcode project. Save the name as: **test**
3. Go to your console in the directory location where your project is located.
4. Type and run the command: **pod init**
5. This will create a file called: **Podfile** in that same location.
6. Edit that **Podfile** so that it looks like the following:


```bash
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'test' do
  use_frameworks!
  pod 'JTAppleCalendar', '~> 7.0'
end
```

Save, and head back to terminal and run: **pod install**.  If all Went well, installation should be complete. Close the XCodeproject, and instead reopen it using the **workspace** file which generated when installation was completed. Done.

### 2. Installing via Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate JTAppleCalendar into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "patchthecode/JTAppleCalendar" ~> 7.0
```

Run `carthage update` to build the framework and drag the built `JTApplecalendar.framework` into your Xcode project.

### 3. Installing manually

Simply drag the source files into your project.



## Author

JayT, patchthecode@gmail.com <-- Sending me emails will not get you a swift response. I check it once every 2 weeks or so. Create a new issue [here on github](https://github.com/patchthecode/JTAppleCalendar/issues) if you need help.

## License

JTAppleCalendar is available under the MIT license. See the LICENSE file for more info.
