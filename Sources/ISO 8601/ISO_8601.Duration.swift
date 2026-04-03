//
//  ISO_8601.Duration.swift
//  swift-iso-8601
//
//  ISO 8601 Duration representation (P format)
//

extension ISO_8601 {
    /// ISO 8601 Duration representation
    ///
    /// Represents a duration of time using the P format: `P[n]Y[n]M[n]DT[n]H[n]M[n]S`
    ///
    /// ## Format
    /// - `P` prefix indicates period/duration
    /// - `T` separates date components from time components
    /// - Components can be omitted if zero
    ///
    /// ## Examples
    /// - `P3Y6M4DT12H30M5S` - 3 years, 6 months, 4 days, 12 hours, 30 minutes, 5 seconds
    /// - `P1Y` - 1 year
    /// - `PT5M` - 5 minutes
    /// - `P3D` - 3 days
    /// - `PT0.5S` - half a second
    ///
    /// ```swift
    /// let duration = try ISO_8601.Duration(years: 1, months: 6, days: 15)
    /// let formatted = duration.description  // "P1Y6M15D"
    /// let parsed = try ISO_8601.Duration.parse("PT2H30M")
    /// ```
    public struct Duration: Sendable, Equatable, Hashable {
        /// Years component
        public let years: Int

        /// Months component (note: month length varies)
        public let months: Int

        /// Days component (note: day length can vary with DST)
        public let days: Int

        /// Hours component
        public let hours: Int

        /// Minutes component
        public let minutes: Int

        /// Seconds component (integer part)
        public let seconds: Int

        /// Nanoseconds component (fractional seconds)
        public let nanoseconds: Int

        /// Create a duration with specified components
        ///
        /// - Parameters:
        ///   - years: Number of years (default: 0)
        ///   - months: Number of months (default: 0)
        ///   - days: Number of days (default: 0)
        ///   - hours: Number of hours (default: 0)
        ///   - minutes: Number of minutes (default: 0)
        ///   - seconds: Number of seconds (default: 0)
        ///   - nanoseconds: Number of nanoseconds (default: 0, range: 0-999999999)
        /// - Throws: `ISO_8601.Date.Error` if nanoseconds is out of range
        public init(
            years: Int = 0,
            months: Int = 0,
            days: Int = 0,
            hours: Int = 0,
            minutes: Int = 0,
            seconds: Int = 0,
            nanoseconds: Int = 0
        ) throws(ISO_8601.Date.Error) {
            guard (0..<1_000_000_000).contains(nanoseconds) else {
                throw ISO_8601.Date.Error.invalidFractionalSecond(String(nanoseconds))
            }

            self.years = years
            self.months = months
            self.days = days
            self.hours = hours
            self.minutes = minutes
            self.seconds = seconds
            self.nanoseconds = nanoseconds
        }

        /// Check if this duration represents zero time
        public var isZero: Bool {
            years == 0 && months == 0 && days == 0 && hours == 0 && minutes == 0 && seconds == 0
                && nanoseconds == 0
        }
    }
}

// MARK: - Formatting

extension ISO_8601.Duration: CustomStringConvertible {
    public var description: String {
        Formatter.format(self)
    }
}

// MARK: - Codable

extension ISO_8601.Duration: Codable {
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
