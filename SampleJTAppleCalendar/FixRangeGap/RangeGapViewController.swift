//
//  RangeGapViewController.swift
//  SampleJTAppleCalendar
//
//  Created by Paul Addy on 29/3/23.
//  Copyright © 2023 OsTech. All rights reserved.
//

import UIKit
import JTAppleCalendar

public class RangeGapViewController: UIViewController {
    lazy var standardLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Calendar:"
        label.textColor = UIColor.gray
        return label
    }()

    lazy var calendar: CalendarPicker = {
        let view = CalendarPicker()
        // observe on selected dates
        view.onSelectedDates = onSelectedDates
        return view
     }()
}

// MARK: - Life Cycle
extension RangeGapViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Helpers - UI
extension RangeGapViewController {
    func setup() {
        setupLabel()
        setupCalendar()
    }

    func setupLabel() {
        self.view.addSubview(standardLabel)
        NSLayoutConstraint.activate([
            standardLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            standardLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
    }

    func setupCalendar() {
        self.view.addSubview(calendar)
        NSLayoutConstraint.activate([
            calendar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            calendar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            calendar.topAnchor.constraint(equalTo: standardLabel.bottomAnchor),
//            calendar.heightAnchor.constraint(equalToConstant:  220),
        ])
        calendar.reset()
    }

    func onSelectedDates(dates: [Date]) {
        print("Selected dates: \(dates)")
    }
}
