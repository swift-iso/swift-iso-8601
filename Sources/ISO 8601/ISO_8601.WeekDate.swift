extension ISO_8601 {

    public struct WeekDate: Sendable, Hashable {

        public let weekYear: Int

        public let week: Int

        public let weekday: Int

        public init(weekYear: Int, week: Int, weekday: Int) throws(Error) {
            guard (1...7).contains(weekday) else { throw .weekdayOutOfRange(weekday) }
            guard Self.weekYears.contains(weekYear) else { throw .yearOutOfRange(weekYear) }
            guard (1...Self.numberOfWeeks(inWeekYear: weekYear)).contains(week) else {
                throw .weekOutOfRange(week, weekYear: weekYear)
            }
            guard
                ISO_8601.CalendarDate.representableDays.contains(
                    Self.daysSinceUnixEpoch(weekYear: weekYear, week: week, weekday: weekday)
                )
            else { throw .yearOutOfRange(weekYear) }
            self.weekYear = weekYear
            self.week = week
            self.weekday = weekday
        }

        public init(_ date: ISO_8601.CalendarDate) {
            let days = date.daysSinceUnixEpoch
            let weekday = ISO_8601.Weekday(daysSinceUnixEpoch: days).isoNumber
            let thursday = ISO_8601.CalendarDate.civil(daysSinceUnixEpoch: days - weekday + 4)
            let thursdayOrdinal =
                days - weekday + 4
                - ISO_8601.CalendarDate.daysSinceUnixEpoch(year: thursday.year, month: 1, day: 1)
            self.weekYear = thursday.year
            self.week = thursdayOrdinal / 7 + 1
            self.weekday = weekday
        }
    }
}

extension ISO_8601.WeekDate {

    public static func numberOfWeeks(inWeekYear weekYear: Int) -> Int {
        switch ISO_8601.Weekday(
            daysSinceUnixEpoch: ISO_8601.CalendarDate.daysSinceUnixEpoch(year: weekYear, month: 1, day: 1)
        ) {
        case .thursday: 53
        case .wednesday: ISO_8601.CalendarDate.isLeapYear(weekYear) ? 53 : 52
        default: 52
        }
    }

    static var weekYears: ClosedRange<Int> {
        ISO_8601.CalendarDate.years.lowerBound - 1...ISO_8601.CalendarDate.years.upperBound + 1
    }

    static func daysSinceUnixEpoch(weekYear: Int, week: Int, weekday: Int) -> Int {
        let january4 = ISO_8601.CalendarDate.daysSinceUnixEpoch(year: weekYear, month: 1, day: 4)
        let mondayOfWeek1 = january4 - ISO_8601.Weekday(daysSinceUnixEpoch: january4).isoNumber + 1
        return mondayOfWeek1 + (week - 1) * 7 + weekday - 1
    }
}
