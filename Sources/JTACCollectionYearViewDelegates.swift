//
//  JTACCollectionYearViewDelegates.swift
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

extension JTACYearView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let delegate = calendarDelegate,
            monthData.count > indexPath.item else {
                print("Invalid startup parameters. Exiting calendar setup.")
                assert(false)
                return UICollectionViewCell()
        }
        
        if let monthData = monthData[indexPath.item] as? Month {
            guard let date = configurationParameters.calendar.date(byAdding: .month, value: monthData.index, to: configurationParameters.startDate) else {
                print("Invalid startup parameters. Exiting calendar setup.")
                assert(false)
                return UICollectionViewCell()
            }
            
            let cell = delegate.calendar(self, cellFor: self.monthData[indexPath.item], at: date, indexPath: indexPath)
            cell.setupWith(configurationParameters: configurationParameters,
                           month: monthData,
                           delegate: self)
            return cell
        } else {
            let date = findFirstMonthCellDate(cellIndex: indexPath.item, monthData: monthData)
            return delegate.calendar(self, cellFor: self.monthData[indexPath.item], at: date, indexPath: indexPath)
        }
    }
    
    func findFirstMonthCellDate(cellIndex: Int, monthData: [Any]) -> Date {
        var retval = configurationParameters.endDate
        for index in cellIndex..<monthData.count {
            if let aMonth = monthData[index] as? Month {
                guard let date = configurationParameters.calendar.date(byAdding: .month, value: aMonth.index, to: configurationParameters.startDate) else {
                    print("Invalid startup parameters. Exiting calendar setup.")
                    assert(false)
                    return configurationParameters.endDate
                }
                retval = date
                break
            }
        }
        
        return retval
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let size = calendarDelegate?.calendar(self, sizeFor: monthData[indexPath.item]) else {
            let width: CGFloat = monthData[indexPath.item] is Month ? (frame.width - 40) / 3 : frame.width
            let height = width
            return CGSize(width: width, height: height)
        }
        return size
    }
}
