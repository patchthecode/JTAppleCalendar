// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JTAppleCalendar",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "JTAppleCalendar",
            targets: ["JTAppleCalendar"]),
    ],
    targets: [
        .target(
            name: "JTAppleCalendar",
            dependencies: []),
        .testTarget(
            name: "JTAppleCalendarTests",
            dependencies: ["JTAppleCalendar"]),
    ]
)
