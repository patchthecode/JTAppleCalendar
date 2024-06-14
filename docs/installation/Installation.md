# Installation

This library can be installed in 3 ways; Cocoapods, Carthage, or manually.

## Via Cocoapods

CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command:

```
gem install cocoapods
```

> [!NOTE]
> CocoaPods 1.1.0+ is required to build JTApplecalendar.

To integrate JTAppleCalendar into your Xcode project using CocoaPods, specify it in your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'JTAppleCalendar', '~>; 7.1'
end
```

Then, run the following command:

```
pod install
```

Once installation is complete, JTAppleCalendar should be installed

## Troubleshooting

If you’re new to CocoaPods, search how to integrate Cocoapods into your project. CocoaPods is one of the top dependency managers for integrating 3rd party frameworks into your project. But in a nut-shell, here is how to complete installation with a sample project called `test`

1. Install Cocoapods
2. Create a new xcode project. Save the name as: `test`
3. Go to your console in the directory location where your project is located
4. Type and run the command: `pod init`

This will create a `Podfile` in that same location

Edit `Podfile` so that it looks like the following:

```
# Uncomment the next line to define a global platform for your project

# platform :ios, '9.0'

target 'test' do
    use_frameworks!
    pod 'JTAppleCalendar'
end
```

Save, and head back to terminal and run: `pod install`

If all went well, installation should be complete. Close the XCodeproject, and instead reopen it using the workspace file which was generated when installation was completed

## Via Carthage

Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following commands:

```
brew update
brew install carthage
```

To integrate JTAppleCalendar into your Xcode project using Carthage, specify it in your `Cartfile`

```
github "patchthecode/JTAppleCalendar" ~> 7.1
```

Run `carthage update` to build the framework and drag the built `JTApplecalendar.framework` into your Xcode project.

## Manually install

Simply drag the source files into your project. Make sure you remove the unnecessary import statements where needed.

## Next steps

Once installed, learn how to [build a calendar from scratch](../build-calendar/Build%20A%20Calendar%20From%20Scratch.md)
