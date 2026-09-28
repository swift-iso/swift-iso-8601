extension ISO_8601.DateTime {

    public enum Formatter {}
}

extension ISO_8601.DateTime.Formatter {

    public static func format(
        _ value: ISO_8601.DateTime,
        date: DateFormat = .calendar(extended: true),
        time: TimeFormat = .time(extended: true),
        timezone: TimezoneFormat = .utc
    ) -> String {
        let seconds = switch (time, timezone) {
        case (.time, .utc):
            value.date.daysSinceUnixEpoch * 86_400 + value.secondOfDay - value.offset.seconds
        case (.none, _), (.time, .none), (.time, .offset):
            value.date.daysSinceUnixEpoch * 86_400 + value.secondOfDay
        }
        let secondOfDay = (seconds % 86_400 + 86_400) % 86_400
        let days = (seconds - secondOfDay) / 86_400
        return switch time {
        case .none:
            formatDate(days: days, format: date)
        case .time(let extended):
            formatDate(days: days, format: date)
                + "T"
                + formatTime(secondOfDay: secondOfDay, nanoseconds: value.nanoseconds, extended: extended)
                + formatTimezone(value.offset, format: timezone)
        }
    }
}

extension ISO_8601.DateTime.Formatter {

    private static func formatDate(days: Int, format: DateFormat) -> String {
        let date = ISO_8601.CalendarDate(unchecked: ISO_8601.CalendarDate.civil(daysSinceUnixEpoch: days))
        let weekDate = ISO_8601.WeekDate(date)
        return switch format {
        case .calendar(let extended):
            [
                ISO_8601.Numeral.padded(date.year, width: 4),
                ISO_8601.Numeral.padded(date.month, width: 2),
                ISO_8601.Numeral.padded(date.day, width: 2),
            ].joined(separator: extended ? "-" : "")

        case .week(let extended):
            [
                ISO_8601.Numeral.padded(weekDate.weekYear, width: 4),
                "W" + ISO_8601.Numeral.padded(weekDate.week, width: 2),
                String(weekDate.weekday),
            ].joined(separator: extended ? "-" : "")

        case .ordinal(let extended):
            [
                ISO_8601.Numeral.padded(date.year, width: 4),
                ISO_8601.Numeral.padded(date.ordinalDay, width: 3),
            ].joined(separator: extended ? "-" : "")
        }
    }

    private static func formatTime(secondOfDay: Int, nanoseconds: Int, extended: Bool) -> String {
        [
            ISO_8601.Numeral.padded(secondOfDay / 3_600, width: 2),
            ISO_8601.Numeral.padded(secondOfDay % 3_600 / 60, width: 2),
            ISO_8601.Numeral.padded(secondOfDay % 60, width: 2),
        ].joined(separator: extended ? ":" : "")
            + ISO_8601.Numeral.fraction(nanoseconds: nanoseconds)
    }

    private static func formatTimezone(_ offset: ISO_8601.Timezone.Offset, format: TimezoneFormat) -> String {
        switch format {
        case .none: ""
        case .utc: "Z"
        case .offset(let extended): offset.formatted(extended: extended)
        }
    }
}
