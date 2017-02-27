//
//  GlobalFunctionsAndExtensions.swift
//  Pods
//
//  Created by JayT on 2016-06-26.
//
//

extension Date {
    
    func startOfMonth() -> Date? {
        
        let calendar = Calendar.current
        let currentDateComponents = calendar.dateComponents([.year, .month], from: self)
        let startOfMonth = calendar.date(from: currentDateComponents)
        
        return startOfMonth
    }
    
    func dateByAddingMonths(_ monthsToAdd: Int) -> Date? {
        
        let calendar = Calendar.current
        var months = DateComponents()
        months.month = monthsToAdd
        
        return calendar.date(byAdding: months, to: self)
    }
    
    func endOfMonth() -> Date? {
        
        guard let plusOneMonthDate = dateByAddingMonths(1) else { return nil }
        
        let calendar = Calendar.current
        let plusOneMonthDateComponents = calendar.dateComponents([.year, .month], from: plusOneMonthDate)
        let endOfMonth = calendar.date(from: plusOneMonthDateComponents)?.addingTimeInterval(-1)
        
        return endOfMonth
        
    }
}

extension Calendar {
    static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        return dateFormatter
    }()
    
    
    func startOfMonth(for date: Date) -> Date? {
        return date.startOfMonth()
    }
    
    func endOfMonth(for date: Date) -> Date? {
        return date.endOfMonth()
    }
    
    private func dateFormatterComponents(from date: Date) -> (month: Int, year: Int)? {
        
        // Setup the dateformatter to this instance's settings
        Calendar.formatter.timeZone = self.timeZone
        Calendar.formatter.locale = self.locale
        
        let comp = self.dateComponents([.year, .month], from: date)
        
        guard
            let month = comp.month,
            let year = comp.year else {
                return nil
        }
        return (month, year)
    }
}

extension Dictionary where Value: Equatable {
    func key(for value: Value) -> Key? {
        guard let index = index(where: { $0.1 == value }) else {
            return nil
        }
        return self[index].0
    }
}
