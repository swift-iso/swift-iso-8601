extension ISO_8601 {

    public struct CalendarDate: Sendable, Hashable {

        public let year: Int

        public let month: Int

        public let day: Int

        public init(year: Int, month: Int, day: Int) throws(Error) {
            guard Self.years.contains(year) else { throw .yearOutOfRange(year) }
            guard (1...12).contains(month) else { throw .monthOutOfRange(month) }
            guard (1...Self.numberOfDays(inMonth: month, year: year)).contains(day) else {
                throw .dayOutOfRange(day, month: month, year: year)
            }
            self.init(unchecked: (year, month, day))
        }

        @usableFromInline
        init(unchecked civil: (year: Int, month: Int, day: Int)) {
            self.year = civil.year
            self.month = civil.month
            self.day = civil.day
        }
    }
}

extension ISO_8601.CalendarDate {

    public static let years: ClosedRange<Int> = 0...9999

    public static func isLeapYear(_ year: Int) -> Bool {
        year.isMultiple(of: 4) && (!year.isMultiple(of: 100) || year.isMultiple(of: 400))
    }

    public static func numberOfDays(inMonth month: Int, year: Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12: 31
        case 4, 6, 9, 11: 30
        case 2: isLeapYear(year) ? 29 : 28
        default: 0
        }
    }

    public static func numberOfDays(inYear year: Int) -> Int {
        isLeapYear(year) ? 366 : 365
    }
}

extension ISO_8601.CalendarDate {

    public init(daysSinceUnixEpoch days: Int) throws(Error) {
        guard Self.representableDays.contains(days) else {
            throw .daysSinceUnixEpochOutOfRange(days)
        }
        self.init(unchecked: Self.civil(daysSinceUnixEpoch: days))
    }

    public var daysSinceUnixEpoch: Int {
        Self.daysSinceUnixEpoch(year: year, month: month, day: day)
    }

    public var weekday: ISO_8601.Weekday {
        ISO_8601.Weekday(daysSinceUnixEpoch: daysSinceUnixEpoch)
    }

    public var ordinalDay: Int {
        daysSinceUnixEpoch - Self.daysSinceUnixEpoch(year: year, month: 1, day: 1) + 1
    }
}

extension ISO_8601.CalendarDate {

    static var representableDays: ClosedRange<Int> {
        daysSinceUnixEpoch(year: years.lowerBound, month: 1, day: 1)
            ... daysSinceUnixEpoch(year: years.upperBound, month: 12, day: 31)
    }

    static func daysSinceUnixEpoch(year: Int, month: Int, day: Int) -> Int {
        let shiftedYear = month <= 2 ? year - 1 : year
        let era = (shiftedYear >= 0 ? shiftedYear : shiftedYear - 399) / 400
        let yearOfEra = shiftedYear - era * 400
        let dayOfYear = (153 * ((month + 9) % 12) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }

    static func civil(daysSinceUnixEpoch days: Int) -> (year: Int, month: Int, day: Int) {
        let shifted = days + 719_468
        let era = (shifted >= 0 ? shifted : shifted - 146_096) / 146_097
        let dayOfEra = shifted - era * 146_097
        let yearOfEra =
            (dayOfEra - dayOfEra / 1_460 + dayOfEra / 36_524 - dayOfEra / 146_096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let shiftedMonth = (5 * dayOfYear + 2) / 153
        let month = shiftedMonth < 10 ? shiftedMonth + 3 : shiftedMonth - 9
        return (
            yearOfEra + era * 400 + (month <= 2 ? 1 : 0),
            month,
            dayOfYear - (153 * shiftedMonth + 2) / 5 + 1
        )
    }
}

extension ISO_8601.CalendarDate: Comparable {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}

extension ISO_8601.CalendarDate {

    public init(_ ordinalDate: ISO_8601.OrdinalDate) {
        self.init(
            unchecked: Self.civil(
                daysSinceUnixEpoch: Self.daysSinceUnixEpoch(year: ordinalDate.year, month: 1, day: 1)
                    + ordinalDate.day - 1
            )
        )
    }

    public init(_ weekDate: ISO_8601.WeekDate) {
        self.init(
            unchecked: Self.civil(
                daysSinceUnixEpoch: ISO_8601.WeekDate.daysSinceUnixEpoch(
                    weekYear: weekDate.weekYear,
                    week: weekDate.week,
                    weekday: weekDate.weekday
                )
            )
        )
    }
}
