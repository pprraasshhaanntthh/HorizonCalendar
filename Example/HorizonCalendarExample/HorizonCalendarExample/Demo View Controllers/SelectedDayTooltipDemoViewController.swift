// Created by Bryan Keller on 6/18/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import HorizonCalendar
import UIKit

// MARK: - SelectedDayTooltipDemoViewController

final class SelectedDayTooltipDemoViewController: UIViewController, DemoViewController {

  // MARK: Lifecycle

  init(monthsLayout: MonthsLayout) {
    self.monthsLayout = monthsLayout
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Selected Day Tooltip"

    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }

    calendarView.daySelectionHandler = { [weak self] day in
      guard let self = self else { return }

      self.selectedDay = day
      self.calendarView.setContent(self.makeContent())
    }
    
    view.addSubview(calendarView)

    calendarView.translatesAutoresizingMaskIntoConstraints = false
    switch monthsLayout {
    case .vertical:
      NSLayoutConstraint.activate([
        calendarView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        calendarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        calendarView.leadingAnchor.constraint(
          greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
        calendarView.trailingAnchor.constraint(
          lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
        calendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        calendarView.widthAnchor.constraint(lessThanOrEqualToConstant: 375)
      ])
    case .horizontal(let monthWidth):
      NSLayoutConstraint.activate([
        calendarView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
        calendarView.heightAnchor.constraint(equalToConstant: monthWidth * 1.1),
        calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      ])
    }
  }

  // MARK: Private

  private let monthsLayout: MonthsLayout

  private lazy var calendarView = CalendarView(initialContent: makeContent())
  private lazy var calendar = Calendar(identifier: .gregorian)
  private lazy var dayDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = calendar
    dateFormatter.dateFormat = DateFormatter.dateFormat(
      fromTemplate: "EEEE, MMM d, yyyy",
      options: 0,
      locale: calendar.locale ?? Locale.current)
    return dateFormatter
  }()

  private var selectedDay: Day?

  private func makeContent() -> CalendarViewContent {
    let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 01))!
    let endDate = calendar.date(from: DateComponents(year: 2021, month: 12, day: 31))!

    let selectedDay = self.selectedDay

    let overlaidItemLocations: Set<CalendarViewContent.OverlaidItemLocation>
    if let selectedDay = selectedDay {
      let dateToOverlay = calendar.date(from: selectedDay.components)!
      overlaidItemLocations = [.day(containingDate: dateToOverlay)]
    } else {
      overlaidItemLocations = []
    }

    return CalendarViewContent(
      calendar: calendar,
      visibleDateRange: startDate...endDate,
      monthsLayout: monthsLayout)

      .withInterMonthSpacing(24)

      .withDayItemProvider { [weak self] day in
        let isSelected = day == selectedDay

        let dayText = "\(day.day)"

        let dayAccessibilityText: String?
        if let date = self?.calendar.date(from: day.components) {
          dayAccessibilityText = self?.dayDateFormatter.string(from: date)
        } else {
          dayAccessibilityText = nil
        }

        return CalendarItem<DayView>(
          initialConfiguration: .init(isSelectedStyle: isSelected),
          viewModel: .init(dayText: dayText, dayAccessibilityText: dayAccessibilityText))
      }

      .withOverlayItemProvider(for: overlaidItemLocations) { overlayLayoutContext in
        CalendarItem<TooltipView>(
          initialConfiguration: .init(),
          viewModel: .init(
            text: "Selected Day",
            frameOfTooltippedItem: overlayLayoutContext.overlaidItemFrame))
      }
  }

}
