//
//  ISO_8601.Time.Formatter.swift
//  swift-iso-8601
//
//  ISO 8601 time formatter
//

import Time_Primitives

extension ISO_8601.Time {
    /// Formatter for ISO 8601 time strings
    public enum Formatter {
        /// Format a time as an ISO 8601 string
        ///
        /// - Parameters:
        ///   - value: The time to format
        ///   - extended: Use extended format with colons (default: true)
        /// - Returns: ISO 8601 time string (e.g., "12:30:45" or "123045")
        public static func format(_ value: ISO_8601.Time, extended: Bool = true) -> String {
            var result = ""

            // Hour (always present)
            let hourStr = value.hour < 10 ? "0\(value.hour)" : "\(value.hour)"

            if let minute = value.minute {
                let minStr = minute < 10 ? "0\(minute)" : "\(minute)"

                if let second = value.second {
                    let secStr = second < 10 ? "0\(second)" : "\(second)"

                    if extended {
                        result = "\(hourStr):\(minStr):\(secStr)"
                    } else {
                        result = "\(hourStr)\(minStr)\(secStr)"
                    }

                    // Add fractional seconds if present
                    if value.nanoseconds > 0 {
                        result += formatFractionalSeconds(value.nanoseconds)
                    }
                } else {
                    // Hour and minute only
                    if extended {
                        result = "\(hourStr):\(minStr)"
                    } else {
                        result = "\(hourStr)\(minStr)"
                    }
                }
            } else {
                // Hour only
                result = hourStr
            }

            // Add timezone if present
            if let offset = value.timezoneOffsetSeconds {
                if offset == 0 {
                    result += "Z"
                } else {
                    result += formatTimezoneOffset(offset, extended: extended)
                }
            }

            return result
        }

        private static func formatFractionalSeconds(_ nanoseconds: Int) -> String {
            // Remove trailing zeros
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
            let hours =
                absOffset / Time_Primitives.Time.Calendar.Gregorian.TimeConstants.secondsPerHour
            let minutes =
                (absOffset % Time_Primitives.Time.Calendar.Gregorian.TimeConstants.secondsPerHour)
                / Time_Primitives.Time.Calendar.Gregorian.TimeConstants.secondsPerMinute

            let hoursStr = hours < 10 ? "0\(hours)" : "\(hours)"
            let minutesStr = minutes < 10 ? "0\(minutes)" : "\(minutes)"

            if extended {
                return "\(sign)\(hoursStr):\(minutesStr)"
            } else {
                return "\(sign)\(hoursStr)\(minutesStr)"
            }
        }
    }
}
