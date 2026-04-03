//
//  ISO_8601.Time.swift
//  swift-iso-8601
//
//  ISO 8601 Time-only representation
//

import Time_Primitives

extension ISO_8601 {
    /// ISO 8601 Time-only representation
    ///
    /// Represents a time of day without a date component per ISO 8601:2019.
    ///
    /// ## Format
    /// - Extended: `HH:MM:SS` or `HH:MM` or `HH`
    /// - Basic: `HHMMSS` or `HHMM` or `HH`
    /// - With timezone: `HH:MM:SSZ` or `HH:MM:SS+05:30`
    /// - With fractional seconds: `HH:MM:SS.sss`
    ///
    /// ## Examples
    /// - `12:30:45` - 12 hours, 30 minutes, 45 seconds
    /// - `12:30` - 12 hours, 30 minutes
    /// - `12` - 12 hours
    /// - `123045` - basic format
    /// - `12:30:45.123Z` - with fractional seconds and UTC
    /// - `12:30:45+05:30` - with timezone offset
    ///
    /// ```swift
    /// let time = try ISO_8601.Time(hour: 12, minute: 30, second: 45)
    /// let formatted = time.description  // "12:30:45"
    /// let parsed = try ISO_8601.Time.Parser.parse("12:30:45Z")
    /// ```
    public struct Time: Sendable, Equatable, Hashable {
        /// Hour component (0-24, where 24 is only valid with minute=0, second=0, nanoseconds=0)
        public let hour: Int

        /// Minute component (0-59), nil for reduced precision
        public let minute: Int?

        /// Second component (0-60, allowing leap second), nil for reduced precision
        public let second: Int?

        /// Nanoseconds component (0-999,999,999)
        public let nanoseconds: Int

        /// Timezone offset in seconds from UTC, nil if not specified
        /// Positive values are east of UTC, negative values are west
        public let timezoneOffsetSeconds: Int?

        /// Create a time with specified components
        ///
        /// - Parameters:
        ///   - hour: Hour (0-24)
        ///   - minute: Minute (0-59, default: nil for reduced precision)
        ///   - second: Second (0-60, default: nil for reduced precision)
        ///   - nanoseconds: Nanoseconds (0-999,999,999, default: 0)
        ///   - timezoneOffsetSeconds: Timezone offset in seconds (default: nil)
        /// - Throws: `ISO_8601.Date.Error` if any component is out of valid range
        public init(
            hour: Int,
            minute: Int? = nil,
            second: Int? = nil,
            nanoseconds: Int = 0,
            timezoneOffsetSeconds: Int? = nil
        ) throws(ISO_8601.Date.Error) {
            // Validate hour (0-24)
            guard (0...24).contains(hour) else {
                throw ISO_8601.Date.Error.hourOutOfRange(hour)
            }

            // If hour is 24, only 24:00:00.0 is valid
            if hour == 24 {
                guard minute == nil || minute == 0,
                    second == nil || second == 0,
                    nanoseconds == 0
                else {
                    throw ISO_8601.Date.Error.invalidTime(
                        "24:xx:xx is not valid, only 24:00:00 is allowed"
                    )
                }
            }

            // Validate minute if present
            if let min = minute {
                guard (0...59).contains(min) else {
                    throw ISO_8601.Date.Error.minuteOutOfRange(min)
                }
            }

            // Validate second if present (allowing 60 for leap second)
            if let sec = second {
                guard (0...60).contains(sec) else {
                    throw ISO_8601.Date.Error.secondOutOfRange(sec)
                }
            }

            // Validate nanoseconds
            guard (0..<1_000_000_000).contains(nanoseconds) else {
                throw ISO_8601.Date.Error.invalidFractionalSecond(String(nanoseconds))
            }

            self.hour = hour
            self.minute = minute
            self.second = second
            self.nanoseconds = nanoseconds
            self.timezoneOffsetSeconds = timezoneOffsetSeconds
        }
    }
}

// MARK: - Formatting

extension ISO_8601.Time: CustomStringConvertible {
    public var description: String {
        Formatter.format(self)
    }
}

// MARK: - Codable

extension ISO_8601.Time: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = try Parser.parse(string)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
