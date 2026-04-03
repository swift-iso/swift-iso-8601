//
//  ISO_8601.DateTime.Formatter.swift
//  swift-iso-8601
//
//  ISO 8601 date-time formatter
//

import Time_Primitives

// MARK: - Formatter

extension ISO_8601.DateTime {
    /// Dedicated formatter for ISO 8601 date-time strings
    ///
    /// Supports all three ISO 8601 date representations:
    /// - Calendar: `2024-01-15` (extended) or `20240115` (basic)
    /// - Week: `2024-W03-2` (extended) or `2024W032` (basic)
    /// - Ordinal: `2024-039` (extended) or `2024039` (basic)
    ///
    /// Can include time and timezone:
    /// - `2024-01-15T12:30:00Z`
    /// - `2024-01-15T12:30:00+05:30`
    /// - `20240115T123000Z` (basic format)
    public enum Formatter {
        /// Date format options
        public enum DateFormat {
            case calendar(extended: Bool)  // YYYY-MM-DD or YYYYMMDD
            case week(extended: Bool)  // YYYY-Www-D or YYYYWwwD
            case ordinal(extended: Bool)  // YYYY-DDD or YYYYDDD
        }

        /// Time format options
        public enum TimeFormat {
            case none
            case time(extended: Bool)  // HH:MM:SS or HHMMSS
        }

        /// Timezone format options
        public enum TimezoneFormat {
            case none
            case utc  // Z
            case offset(extended: Bool)  // +05:30 or +0530
        }

        /// Format a DateTime as ISO 8601 string
        ///
        /// - Parameters:
        ///   - value: The DateTime to format
        ///   - date: Date format (default: calendar extended)
        ///   - time: Time format (default: extended time)
        ///   - timezone: Timezone format (default: UTC 'Z')
        /// - Returns: ISO 8601 formatted string
        public static func format(
            _ value: ISO_8601.DateTime,
            date: DateFormat = .calendar(extended: true),
            time: TimeFormat = .time(extended: true),
            timezone: TimezoneFormat = .utc
        ) -> String {
            var result = ""

            // Format date portion
            switch date {
            case .calendar(let extended):
                result += formatCalendarDate(value, extended: extended)
            case .week(let extended):
                result += formatWeekDate(value, extended: extended)
            case .ordinal(let extended):
                result += formatOrdinalDate(value, extended: extended)
            }

            // Format time portion if requested
            switch time {
            case .none:
                break
            case .time(let extended):
                result += "T"
                result += formatTime(value, extended: extended)

                // Format timezone if time is included
                switch timezone {
                case .none:
                    break
                case .utc:
                    result += "Z"
                case .offset(let extended):
                    result += formatTimezoneOffset(value.timezone.offsetSeconds, extended: extended)
                }
            }

            return result
        }

        // MARK: - Private Formatting Helpers

        private static func formatCalendarDate(_ value: ISO_8601.DateTime, extended: Bool) -> String
        {
            let comp = value.components
            let year = formatFourDigits(comp.year)
            let month = formatTwoDigits(comp.month)
            let day = formatTwoDigits(comp.day)

            if extended {
                return "\(year)-\(month)-\(day)"
            } else {
                return "\(year)\(month)\(day)"
            }
        }

        private static func formatWeekDate(_ value: ISO_8601.DateTime, extended: Bool) -> String {
            let year = formatFourDigits(value.isoWeekYear)
            let week = formatTwoDigits(value.isoWeek)
            let weekday = value.isoWeekday

            if extended {
                return "\(year)-W\(week)-\(weekday)"
            } else {
                return "\(year)W\(week)\(weekday)"
            }
        }

        private static func formatOrdinalDate(_ value: ISO_8601.DateTime, extended: Bool) -> String
        {
            let comp = value.components
            let year = formatFourDigits(comp.year)
            let day = formatThreeDigits(value.ordinalDay)

            if extended {
                return "\(year)-\(day)"
            } else {
                return "\(year)\(day)"
            }
        }

        private static func formatTime(_ value: ISO_8601.DateTime, extended: Bool) -> String {
            let comp = value.components
            let hour = formatTwoDigits(comp.hour)
            let minute = formatTwoDigits(comp.minute)
            let second = formatTwoDigits(comp.second)

            var result: String
            if extended {
                result = "\(hour):\(minute):\(second)"
            } else {
                result = "\(hour)\(minute)\(second)"
            }

            // Add fractional seconds if present
            if comp.nanoseconds > 0 {
                result += formatFractionalSeconds(comp.nanoseconds)
            }

            return result
        }

        private static func formatFractionalSeconds(_ nanoseconds: Int) -> String {
            // Remove trailing zeros from nanoseconds
            var nano = nanoseconds
            while nano > 0 && nano % 10 == 0 {
                nano /= 10
            }

            if nano == 0 {
                return ""
            }

            return ".\(nano)"
        }

        private static func formatTimezoneOffset(_ offsetSeconds: Int, extended: Bool) -> String {
            let sign = offsetSeconds >= 0 ? "+" : "-"
            let absOffset = abs(offsetSeconds)
            let hours = absOffset / Time.Calendar.Gregorian.TimeConstants.secondsPerHour
            let minutes =
                (absOffset % Time.Calendar.Gregorian.TimeConstants.secondsPerHour)
                / Time.Calendar.Gregorian.TimeConstants.secondsPerMinute

            let hoursStr = formatTwoDigits(hours)
            let minutesStr = formatTwoDigits(minutes)

            if extended {
                return "\(sign)\(hoursStr):\(minutesStr)"
            } else {
                return "\(sign)\(hoursStr)\(minutesStr)"
            }
        }

        // MARK: - Digit Formatting Helpers

        /// Fast two-digit zero-padded formatting (00-99)
        private static func formatTwoDigits(_ value: Int) -> String {
            let tens = value / 10
            let ones = value % 10
            return "\(tens)\(ones)"
        }

        /// Fast three-digit zero-padded formatting (000-999)
        private static func formatThreeDigits(_ value: Int) -> String {
            let hundreds = value / 100
            let tens = (value % 100) / 10
            let ones = value % 10
            return "\(hundreds)\(tens)\(ones)"
        }

        /// Fast four-digit zero-padded formatting (0000-9999)
        private static func formatFourDigits(_ value: Int) -> String {
            let thousands = value / 1000
            let hundreds = (value % 1000) / 100
            let tens = (value % 100) / 10
            let ones = value % 10
            return "\(thousands)\(hundreds)\(tens)\(ones)"
        }
    }
}
