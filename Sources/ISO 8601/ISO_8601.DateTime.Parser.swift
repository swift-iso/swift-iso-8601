//
//  ISO_8601.DateTime.Parser.swift
//  swift-iso-8601
//
//  ISO 8601 date-time parser
//

import Time_Primitives

// MARK: - Parser

extension ISO_8601.DateTime {
    /// Dedicated parser for ISO 8601 date-time strings
    ///
    /// Supports all three ISO 8601 date representations in both extended and basic formats:
    /// - Calendar: `2024-01-15` or `20240115`
    /// - Week: `2024-W03-2` or `2024W032`
    /// - Ordinal: `2024-039` or `2024039`
    ///
    /// With optional time and timezone:
    /// - `2024-01-15T12:30:00Z`
    /// - `2024-01-15T12:30:00+05:30`
    /// - `20240115T123000Z`
    public enum Parser {
        /// Parse an ISO 8601 date-time string
        ///
        /// - Parameter value: The ISO 8601 formatted string
        /// - Returns: DateTime instance
        /// - Throws: `ISO_8601.Date.Error` if parsing fails
        public static func parse(_ value: String) throws(ISO_8601.Date.Error) -> ISO_8601.DateTime {
            // Split on 'T' to separate date and time portions
            let parts = value.split(separator: "T", maxSplits: 1).map(String.init)

            guard !parts.isEmpty else {
                throw ISO_8601.Date.Error.invalidFormat("Empty string")
            }

            let datePart = parts[0]
            let timePart = parts.count > 1 ? parts[1] : nil

            // Parse date portion (detect format)
            let (year, month, day) = try parseDate(datePart)

            // Parse time portion if present
            var hour = 0
            var minute = 0
            var second = 0
            var nanoseconds = 0
            var timezoneOffset = 0

            if let time = timePart {
                (hour, minute, second, nanoseconds, timezoneOffset) = try parseTime(time)
            }

            // Handle 24:00:00 (midnight at end of day)
            // ISO 8601: 24:00:00 = 00:00:00 of next day
            if hour == 24 {
                guard minute == 0 && second == 0 && nanoseconds == 0 else {
                    throw ISO_8601.Date.Error.invalidTime(
                        "24:xx:xx is not valid, only 24:00:00 is allowed"
                    )
                }

                // Advance to next day at 00:00:00
                hour = 0
                let nextDayDateTime = try ISO_8601.DateTime(
                    year: year,
                    month: month,
                    day: day,
                    hour: 0,
                    minute: 0,
                    second: 0,
                    nanoseconds: 0,
                    timezoneOffsetSeconds: timezoneOffset
                )
                // Add one day (86400 seconds)
                return try ISO_8601.DateTime(
                    secondsSinceEpoch: nextDayDateTime.secondsSinceEpoch
                        + Time.Calendar.Gregorian.TimeConstants.secondsPerDay,
                    nanoseconds: 0,
                    timezoneOffsetSeconds: timezoneOffset
                )
            }

            // Create DateTime
            return try ISO_8601.DateTime(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                nanoseconds: nanoseconds,
                timezoneOffsetSeconds: timezoneOffset
            )
        }

        // MARK: - Date Parsing

        private static func parseDate(_ value: String) throws(ISO_8601.Date.Error) -> (year: Int, month: Int, day: Int) {
            // Detect format by looking for specific patterns
            if value.contains("W") {
                return try parseWeekDate(value)
            } else if value.count >= 7 && (value.count == 7 || value.count == 8)
                && !value.contains("-")
            {
                // Could be basic ordinal (YYYYDDD) or basic calendar (YYYYMMDD)
                if value.count == 7 {
                    return try parseOrdinalDate(value)
                } else {
                    return try parseCalendarDate(value)
                }
            } else if value.contains("-") {
                // Extended format - check length to distinguish
                let dashCount = value.filter { $0 == "-" }.count
                if dashCount == 1 {
                    // YYYY-DDD (ordinal extended)
                    return try parseOrdinalDate(value)
                } else {
                    // YYYY-MM-DD (calendar extended)
                    return try parseCalendarDate(value)
                }
            } else {
                // Basic calendar format YYYYMMDD
                return try parseCalendarDate(value)
            }
        }

        private static func parseCalendarDate(
            _ value: String
        ) throws(ISO_8601.Date.Error) -> (year: Int, month: Int, day: Int) {
            if value.contains("-") {
                // Extended format: YYYY-MM-DD
                let parts = value.split(separator: "-").map(String.init)
                guard parts.count == 3 else {
                    throw ISO_8601.Date.Error.invalidFormat("Expected YYYY-MM-DD")
                }

                guard let year = Int(parts[0]) else {
                    throw ISO_8601.Date.Error.invalidYear(parts[0])
                }
                guard let month = Int(parts[1]) else {
                    throw ISO_8601.Date.Error.invalidMonth(parts[1])
                }
                guard let day = Int(parts[2]) else {
                    throw ISO_8601.Date.Error.invalidDay(parts[2])
                }

                return (year, month, day)
            } else {
                // Basic format: YYYYMMDD
                guard value.count == 8 else {
                    throw ISO_8601.Date.Error.invalidFormat("Expected YYYYMMDD (8 digits)")
                }

                let yearStr = String(value.prefix(4))
                let monthStr = String(value.dropFirst(4).prefix(2))
                let dayStr = String(value.dropFirst(6))

                guard let year = Int(yearStr) else {
                    throw ISO_8601.Date.Error.invalidYear(yearStr)
                }
                guard let month = Int(monthStr) else {
                    throw ISO_8601.Date.Error.invalidMonth(monthStr)
                }
                guard let day = Int(dayStr) else {
                    throw ISO_8601.Date.Error.invalidDay(dayStr)
                }

                return (year, month, day)
            }
        }

        private static func parseWeekDate(
            _ value: String
        ) throws(ISO_8601.Date.Error) -> (year: Int, month: Int, day: Int) {
            if value.contains("-") {
                // Extended format: YYYY-Www-D
                let parts = value.split(separator: "-").map(String.init)
                guard parts.count == 3 else {
                    throw ISO_8601.Date.Error.invalidFormat("Expected YYYY-Www-D")
                }

                guard let weekYear = Int(parts[0]) else {
                    throw ISO_8601.Date.Error.invalidYear(parts[0])
                }

                // Parse week (remove 'W' prefix)
                guard parts[1].hasPrefix("W") else {
                    throw ISO_8601.Date.Error.invalidFormat("Week part must start with 'W'")
                }
                let weekStr = String(parts[1].dropFirst())
                guard let week = Int(weekStr) else {
                    throw ISO_8601.Date.Error.invalidWeekNumber(weekStr)
                }

                guard let weekday = Int(parts[2]) else {
                    throw ISO_8601.Date.Error.invalidWeekday(parts[2])
                }

                let weekDate = try ISO_8601.WeekDate(
                    weekYear: weekYear,
                    week: week,
                    weekday: weekday
                )
                let dateTime = ISO_8601.DateTime(weekDate)
                let comp = dateTime.components
                return (comp.year, comp.month, comp.day)
            } else {
                // Basic format: YYYYWwwD
                guard value.count == 8, value.contains("W") else {
                    throw ISO_8601.Date.Error.invalidFormat("Expected YYYYWwwD")
                }

                let yearStr = String(value.prefix(4))
                guard let weekYear = Int(yearStr) else {
                    throw ISO_8601.Date.Error.invalidYear(yearStr)
                }

                // Find W position
                guard let wIndex = value.firstIndex(of: "W") else {
                    throw ISO_8601.Date.Error.invalidFormat("Missing 'W' in week date")
                }

                let afterW = value.index(after: wIndex)
                let weekStr = String(value[afterW..<value.index(afterW, offsetBy: 2)])
                let weekdayStr = String(value[value.index(afterW, offsetBy: 2)])

                guard let week = Int(weekStr) else {
                    throw ISO_8601.Date.Error.invalidWeekNumber(weekStr)
                }
                guard let weekday = Int(weekdayStr) else {
                    throw ISO_8601.Date.Error.invalidWeekday(weekdayStr)
                }

                let weekDate = try ISO_8601.WeekDate(
                    weekYear: weekYear,
                    week: week,
                    weekday: weekday
                )
                let dateTime = ISO_8601.DateTime(weekDate)
                let comp = dateTime.components
                return (comp.year, comp.month, comp.day)
            }
        }

        private static func parseOrdinalDate(
            _ value: String
        ) throws(ISO_8601.Date.Error) -> (year: Int, month: Int, day: Int) {
            if value.contains("-") {
                // Extended format: YYYY-DDD
                let parts = value.split(separator: "-").map(String.init)
                guard parts.count == 2 else {
                    throw ISO_8601.Date.Error.invalidFormat("Expected YYYY-DDD")
                }

                guard let year = Int(parts[0]) else {
                    throw ISO_8601.Date.Error.invalidYear(parts[0])
                }
                guard let ordinalDay = Int(parts[1]) else {
                    throw ISO_8601.Date.Error.invalidOrdinalDay(parts[1])
                }

                let ordinal = try ISO_8601.OrdinalDate(year: year, day: ordinalDay)
                let dateTime = ISO_8601.DateTime(ordinal)
                let comp = dateTime.components
                return (comp.year, comp.month, comp.day)
            } else {
                // Basic format: YYYYDDD
                guard value.count == 7 else {
                    throw ISO_8601.Date.Error.invalidFormat("Expected YYYYDDD (7 digits)")
                }

                let yearStr = String(value.prefix(4))
                let dayStr = String(value.dropFirst(4))

                guard let year = Int(yearStr) else {
                    throw ISO_8601.Date.Error.invalidYear(yearStr)
                }
                guard let ordinalDay = Int(dayStr) else {
                    throw ISO_8601.Date.Error.invalidOrdinalDay(dayStr)
                }

                let ordinal = try ISO_8601.OrdinalDate(year: year, day: ordinalDay)
                let dateTime = ISO_8601.DateTime(ordinal)
                let comp = dateTime.components
                return (comp.year, comp.month, comp.day)
            }
        }

        // MARK: - Time Parsing

        private static func parseTime(
            _ value: String
        ) throws(ISO_8601.Date.Error) -> (hour: Int, minute: Int, second: Int, nanoseconds: Int, timezoneOffset: Int) {
            // Extract timezone portion (Z, +HH:MM, -HH:MM, etc.)
            var timePart = value
            var timezoneOffset = 0

            if value.hasSuffix("Z") {
                timePart = String(value.dropLast())
                timezoneOffset = 0
            } else if let plusIndex = value.lastIndex(of: "+") {
                timePart = String(value[..<plusIndex])
                let tzPart = String(value[value.index(after: plusIndex)...])
                timezoneOffset = try parseTimezoneOffset(tzPart, positive: true)
            } else if let minusIndex = value.lastIndex(of: "-"), minusIndex != value.startIndex {
                timePart = String(value[..<minusIndex])
                let tzPart = String(value[value.index(after: minusIndex)...])
                timezoneOffset = try parseTimezoneOffset(tzPart, positive: false)
            }

            // Parse time components
            var hour = 0
            var minute = 0
            var second = 0
            var nanoseconds = 0

            if timePart.contains(":") {
                // Extended format: HH:MM:SS or HH:MM
                let parts = timePart.split(separator: ":").map(String.init)
                guard parts.count >= 2 else {
                    throw ISO_8601.Date.Error.invalidTime("Expected HH:MM or HH:MM:SS")
                }

                guard let h = Int(parts[0]) else {
                    throw ISO_8601.Date.Error.invalidHour(parts[0])
                }
                guard let m = Int(parts[1]) else {
                    throw ISO_8601.Date.Error.invalidMinute(parts[1])
                }

                hour = h
                minute = m

                if parts.count >= 3 {
                    // Parse seconds and fractional seconds
                    (second, nanoseconds) = try parseFractionalSeconds(parts[2])
                }
            } else {
                // Basic format: HHMMSS or HHMM
                if timePart.count >= 4 {
                    let hourStr = String(timePart.prefix(2))
                    let minuteStr = String(timePart.dropFirst(2).prefix(2))

                    guard let h = Int(hourStr) else {
                        throw ISO_8601.Date.Error.invalidHour(hourStr)
                    }
                    guard let m = Int(minuteStr) else {
                        throw ISO_8601.Date.Error.invalidMinute(minuteStr)
                    }

                    hour = h
                    minute = m

                    if timePart.count >= 6 {
                        // Check for fractional seconds in basic format
                        let remainingPart = String(timePart.dropFirst(4))
                        if remainingPart.contains(".") || remainingPart.contains(",") {
                            (second, nanoseconds) = try parseFractionalSeconds(remainingPart)
                        } else {
                            let secondStr = String(remainingPart.prefix(2))
                            guard let s = Int(secondStr) else {
                                throw ISO_8601.Date.Error.invalidSecond(secondStr)
                            }
                            second = s
                        }
                    }
                } else {
                    throw ISO_8601.Date.Error.invalidTime("Time too short")
                }
            }

            return (hour, minute, second, nanoseconds, timezoneOffset)
        }

        private static func parseFractionalSeconds(
            _ value: String
        ) throws(ISO_8601.Date.Error) -> (seconds: Int, nanoseconds: Int) {
            // Check for decimal point or comma
            let separator: Character
            if value.contains(".") {
                separator = "."
            } else if value.contains(",") {
                separator = ","
            } else {
                // No fractional part
                guard let s = Int(value) else {
                    throw ISO_8601.Date.Error.invalidSecond(value)
                }
                return (s, 0)
            }

            let comps = value.split(separator: separator).map(String.init)
            guard comps.count == 2 else {
                throw ISO_8601.Date.Error.invalidFormat("Invalid fractional seconds")
            }

            guard let sec = Int(comps[0]) else {
                throw ISO_8601.Date.Error.invalidSecond(comps[0])
            }

            // Parse fractional part
            let fracStr = comps[1]
            // Pad or truncate to 9 digits (nanoseconds)
            var paddedFrac = fracStr
            if fracStr.count < 9 {
                paddedFrac = fracStr + String(repeating: "0", count: 9 - fracStr.count)
            } else if fracStr.count > 9 {
                paddedFrac = String(fracStr.prefix(9))
            }
            guard let nano = Int(paddedFrac) else {
                throw ISO_8601.Date.Error.invalidFractionalSecond(fracStr)
            }

            return (sec, nano)
        }

        private static func parseTimezoneOffset(_ value: String, positive: Bool) throws(ISO_8601.Date.Error) -> Int {
            if value.contains(":") {
                // Extended format: HH:MM
                let parts = value.split(separator: ":").map(String.init)
                guard parts.count == 2 else {
                    throw ISO_8601.Date.Error.invalidTimezone(value)
                }

                guard let hours = Int(parts[0]), let minutes = Int(parts[1]) else {
                    throw ISO_8601.Date.Error.invalidTimezone(value)
                }

                let offset =
                    hours * Time.Calendar.Gregorian.TimeConstants.secondsPerHour + minutes
                    * Time.Calendar.Gregorian.TimeConstants.secondsPerMinute
                return positive ? offset : -offset
            } else {
                // Basic format: HHMM
                guard value.count == 4 else {
                    throw ISO_8601.Date.Error.invalidTimezone(value)
                }

                let hoursStr = String(value.prefix(2))
                let minutesStr = String(value.dropFirst(2))

                guard let hours = Int(hoursStr), let minutes = Int(minutesStr) else {
                    throw ISO_8601.Date.Error.invalidTimezone(value)
                }

                let offset =
                    hours * Time.Calendar.Gregorian.TimeConstants.secondsPerHour + minutes
                    * Time.Calendar.Gregorian.TimeConstants.secondsPerMinute
                return positive ? offset : -offset
            }
        }
    }
}
