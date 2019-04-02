// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JTAppleCalendar",
    products: [
       .library(name: "JTAppleCalendar", targets: ["JTAppleCalendar"])
   ],
   targets: [
       .target(
           name: "JTAppleCalendar",
           path: "Sources"
       )
   ]
)
