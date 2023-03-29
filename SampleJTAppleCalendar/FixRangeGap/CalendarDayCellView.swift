//
//  CalendarDayCellView.swift
//  SampleJTAppleCalendar
//
//  Created by Paul Addy on 29/3/23.
//  Copyright © 2023 OsTech. All rights reserved.
//

import JTAppleCalendar
import UIKit

public class CalendarDayCellView: JTACDayCell {
    // MARK: - Properties
    private let ovalDiameter: CGFloat = 32
    enum InRangeStatus {
        case startOfRange
        case betweenRange
        case endOfRange
        case none
    }

    var isEnabled = true {
        didSet {
            update()
        }
    }

    var isToday = false
    var inRangeStatus = InRangeStatus.none

    // MARK: - UI
    lazy var dayLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.accessibilityIdentifier = "dayLabel"
        return dateLabel
    }()

    let containerView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "containerView"
        return view
    }()

    lazy var selectedView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "selectedView"
//        view.theme_backgroundColor = picker.color.container.selected
        view.backgroundColor = .green.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()

    lazy var inRangeLeftView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "inRangeLeftView"
//        view.theme_backgroundColor = picker.color.container.range
        view.backgroundColor = .red
        view.isHidden = true
        return view
    }()

    lazy var inRangeRightView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "inRangeRightView"
//        view.theme_backgroundColor = picker.color.container.range
        view.backgroundColor = .red
        view.isHidden = true
        return view
    }()

    // MARK: - Setups

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
        containerView.fillSuperview(padding: padding)
//        guard let superview = superview else {
//            assertionFailure("missing data")
//            return
//        }
//        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0),
//            containerView.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: 0),
//            containerView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 4),
//            containerView.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: 0),
//        ])

        layoutIfNeeded()

        containerView.addSubview(inRangeLeftView)
        containerView.addSubview(inRangeRightView)
        containerView.addSubview(selectedView)
        containerView.addSubview(dayLabel)
        setupInRangeViews()
        setupSelectedView()
        setupDayLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Helpers
extension CalendarDayCellView {
    func setupSelectedView() {
        selectedView.anchor(
            .width(ovalDiameter),
            .height(ovalDiameter)
        )
        selectedView.layer.cornerRadius = ovalDiameter / 2

        NSLayoutConstraint.activate([
            selectedView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            selectedView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    func setupDayLabel() {
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.anchor(
            .height(40)
        )

        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: selectedView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: selectedView.centerYAnchor, constant: -1)
        ])
    }

    func setupInRangeViews() {
        inRangeLeftView.anchor(
            .leading(leadingAnchor),
            .trailing(centerXAnchor),
            .height(20)
        )
        inRangeLeftView.centerYTo(containerView.centerYAnchor)

        inRangeRightView.anchor(
            .leading(centerXAnchor),
            .trailing(trailingAnchor),
            .height(20)
        )
        inRangeRightView.centerYTo(containerView.centerYAnchor)
    }

    func configureForDisplay(
        text: String,
        isEnabled: Bool,
        isHidden: Bool,
        isSelected: Bool,
        isToday: Bool,
        inRangeStatus: InRangeStatus
    ) {
        dayLabel.text = text
        self.isEnabled = isEnabled
        self.isHidden = isHidden
        self.isSelected = isSelected
        self.isToday = isToday
        self.inRangeStatus = inRangeStatus
        update()
    }

    func update() {
        inRangeLeftView.isHidden = (inRangeStatus == .startOfRange || inRangeStatus == .none)
        inRangeRightView.isHidden = (inRangeStatus == .endOfRange || inRangeStatus == .none)
        selectedView.isHidden = !isSelected

        if isSelected {
//            dayLabel.theme_textColor = picker.color.text.date.selection
            dayLabel.textColor = .green
//            dayLabel.theme_textAttributes = picker.font.date.selectedAttributedText
        } else if inRangeStatus == .betweenRange {
//            dayLabel.theme_textColor = picker.color.text.date.selection
            dayLabel.textColor = .purple
//            dayLabel.theme_textAttributes = picker.font.date.defaultValueAttributedText
        } else if isToday {
//            dayLabel.theme_textColor = picker.color.text.date.today
            dayLabel.textColor = .blue
//            dayLabel.theme_textAttributes = picker.font.date.defaultValueAttributedText
        } else if isEnabled {
//            dayLabel.theme_textColor = picker.color.text.date.defaultValue
            dayLabel.textColor = .black
//            dayLabel.theme_textAttributes = picker.font.date.defaultValueAttributedText
        } else {
            // disabled
//            dayLabel.theme_textColor = picker.color.text.date.disabled
            dayLabel.textColor = .lightGray
//            dayLabel.theme_textAttributes = picker.font.date.defaultValueAttributedText
        }
    }
}
