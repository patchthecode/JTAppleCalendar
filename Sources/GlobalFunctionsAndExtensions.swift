//
//  GlobalFunctionsAndExtensions.swift
//  Pods
//
//  Created by JayT on 2016-06-26.
//
//

func delayRunOnMainThread(_ delay: TimeInterval, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
}

func delayRunOnGlobalThread(_ delay: TimeInterval, qos: DispatchQoS.QoSClass, closure: @escaping () -> ()) {
    DispatchQueue.global(qos: qos).asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
}

/// NSDates can be compared with the == and != operators
public func ==(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedSame
}
/// NSDates can be compared with the > and < operators
public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

extension Date {
    static func startOfMonthForDate(_ date: Date, usingCalendar calendar:Calendar) -> Date? {
        let dayOneComponents = calendar.dateComponents([.era, .year, .month], from: date)
        return calendar.date(from: dayOneComponents)
    }
    
    static func endOfMonthForDate(_ date: Date, usingCalendar calendar:Calendar) -> Date? {
        var lastDayComponents = calendar.dateComponents([.era, .year, .month], from: date)
        lastDayComponents.month = lastDayComponents.month! + 1
        lastDayComponents.day = 0
        return calendar.date(from: lastDayComponents)
    }
}
