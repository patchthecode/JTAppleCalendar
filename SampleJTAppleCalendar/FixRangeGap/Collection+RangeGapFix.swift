//
//  Collection+RangeGapFix.swift
//  SampleJTAppleCalendar
//
//  Created by Paul Addy on 29/3/23.
//  Copyright © 2023 OsTech. All rights reserved.
//

import Foundation

public extension Collection where Indices.Iterator.Element == Index {
    subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}
