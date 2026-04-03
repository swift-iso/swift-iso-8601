//
//  ISO_8601.Duration.Formatter.swift
//  swift-iso-8601
//
//  ISO 8601 duration formatter
//

extension ISO_8601.Duration {
    /// Formatter for ISO 8601 duration strings
    public enum Formatter {
        /// Format a duration as an ISO 8601 P-format string
        ///
        /// - Parameter value: The duration to format
        /// - Returns: ISO 8601 duration string (e.g., "P1Y2M3DT4H5M6.789S")
        public static func format(_ value: ISO_8601.Duration) -> String {
            // Handle zero duration
            if value.isZero {
                return "PT0S"
            }

            var result = "P"

            // Date components
            if value.years != 0 {
                result += "\(value.years)Y"
            }
            if value.months != 0 {
                result += "\(value.months)M"
            }
            if value.days != 0 {
                result += "\(value.days)D"
            }

            // Time components
            let hasTimeComponents =
                value.hours != 0 || value.minutes != 0 || value.seconds != 0
                || value.nanoseconds != 0

            if hasTimeComponents {
                result += "T"

                if value.hours != 0 {
                    result += "\(value.hours)H"
                }
                if value.minutes != 0 {
                    result += "\(value.minutes)M"
                }
                if value.seconds != 0 || value.nanoseconds != 0 {
                    if value.nanoseconds == 0 {
                        result += "\(value.seconds)S"
                    } else {
                        // Format fractional seconds
                        let fractional = formatFractionalSeconds(
                            seconds: value.seconds,
                            nanoseconds: value.nanoseconds
                        )
                        result += "\(fractional)S"
                    }
                }
            }

            return result
        }

        private static func formatFractionalSeconds(seconds: Int, nanoseconds: Int) -> String {
            // Remove trailing zeros from nanoseconds
            var nano = nanoseconds
            var divisor = 1
            while nano > 0 && nano % 10 == 0 {
                nano /= 10
                divisor *= 10
            }

            if nano == 0 {
                return "\(seconds)"
            }

            return "\(seconds).\(nano)"
        }
    }
}
