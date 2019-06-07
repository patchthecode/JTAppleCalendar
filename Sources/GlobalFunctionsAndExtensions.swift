//
//  GlobalFunctionsAndExtensions.swift
//
//  Copyright (c) 2016-2017 JTAppleCalendar (https://github.com/patchthecode/JTAppleCalendar)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension Calendar {
    static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.isLenient = true
        return dateFormatter
    }()
    

    func startOfMonth(for date: Date) -> Date? {
        guard let interval = self.dateInterval(of: .month, for: date) else { return nil }
        return interval.start
    }
    
    func endOfMonth(for date: Date) -> Date? {
        guard let interval = self.dateInterval(of: .month, for: date) else { return nil }
        return self.date(byAdding: DateComponents(day: -1), to: interval.end)
    }
    
    private func dateFormatterComponents(from date: Date) -> (month: Int, year: Int)? {
        
        // Setup the dateformatter to this instance's settings
        Calendar.formatter.timeZone = self.timeZone
        Calendar.formatter.locale = self.locale
        Calendar.formatter.calendar = self
        
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
        guard let index = firstIndex(where: { $0.1 == value }) else {
            return nil
        }
        return self[index].0
    }
}
