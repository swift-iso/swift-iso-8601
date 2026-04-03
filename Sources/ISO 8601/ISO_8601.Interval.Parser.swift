//
//  ISO_8601.Interval.Parser.swift
//  swift-iso-8601
//
//  ISO 8601 interval parser
//

// MARK: - Parsing

extension ISO_8601.Interval {
    /// Parser for ISO 8601 interval strings
    public enum Parser {
        /// Parse an ISO 8601 interval string
        ///
        /// - Parameter value: The interval string (e.g., "2019-08-27/2019-08-29", "P3D", "2019-08-27/P3D")
        /// - Returns: Interval instance
        /// - Throws: `ISO_8601.Date.Error` if parsing fails
        public static func parse(_ value: String) throws(ISO_8601.Date.Error) -> ISO_8601.Interval {
            // Check if it's a duration-only interval (starts with P, no slash)
            if value.hasPrefix("P") && !value.contains("/") {
                let duration = try ISO_8601.Duration.Parser.parse(value)
                return .duration(duration)
            }

            // Split on slash
            let parts = value.split(separator: "/", maxSplits: 1).map(String.init)
            guard parts.count == 2 else {
                throw ISO_8601.Date.Error.invalidFormat(
                    "Interval must have format: start/end, start/duration, or duration/end"
                )
            }

            let first = parts[0]
            let second = parts[1]

            // Determine which format based on presence of 'P'
            let firstIsDuration = first.hasPrefix("P")
            let secondIsDuration = second.hasPrefix("P")

            if firstIsDuration && secondIsDuration {
                throw ISO_8601.Date.Error.invalidFormat("Interval cannot have two durations")
            }

            if firstIsDuration {
                // Duration/End
                let duration = try ISO_8601.Duration.Parser.parse(first)
                let end = try ISO_8601.DateTime.Parser.parse(second)
                return .durationEnd(duration: duration, end: end)
            } else if secondIsDuration {
                // Start/Duration
                let start = try ISO_8601.DateTime.Parser.parse(first)
                let duration = try ISO_8601.Duration.Parser.parse(second)
                return .startDuration(start: start, duration: duration)
            } else {
                // Start/End
                let start = try ISO_8601.DateTime.Parser.parse(first)
                let end = try ISO_8601.DateTime.Parser.parse(second)
                return .startEnd(start: start, end: end)
            }
        }
    }
}
