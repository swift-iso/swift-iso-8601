//
//  ISO_8601.DateTime.swift
//  swift-iso-8601
//
//  Core date-time representation following ISO 8601:2019
//

public import Time_Primitives
import Standard_Library_Extensions

extension ISO_8601 {

    public typealias Date = DateTime

    /// ISO 8601 date-time representation
    ///
    /// Represents a date-time value per ISO 8601:2019.
    /// Uses Standards/Time as the foundation for all calendar logic.
    ///
    /// ## Three Representations
    ///
    /// ISO 8601 supports three different date representations:
    /// - **Calendar Date**: Year-Month-Day (most common)
    /// - **Week Date**: Year-Week-Weekday
    /// - **Ordinal Date**: Year-DayOfYear
    ///
    /// ## Example
    ///
    /// ```swift
    /// let dateTime = try ISO_8601.DateTime(year: 2024, month: 1, day: 15, hour: 12, minute: 30)
    /// print(ISO_8601.DateTime.Formatter.format(dateTime))
    /// // "2024-01-15T12:30:00Z"
    /// ```
    public struct DateTime: Sendable, Equatable, Hashable, Comparable {
        /// The UTC time
        public let time: Time_Primitives.Time

        /// Timezone offset from UTC
        /// Positive values are east of UTC, negative values are west
        /// Example: +0100 = 1 hour, -0500 = -5 hours
        public let timezoneOffset: Time_Primitives.Time.Timezone.Offset

        /// Create a date-time from Time and timezone offset
        /// - Parameters:
        ///   - time: The UTC time
        ///   - timezoneOffset: Timezone offset (default: UTC)
        public init(
            time: Time_Primitives.Time,
            timezoneOffset: Time_Primitives.Time.Timezone.Offset = .utc
        ) {
            self.time = time
            self.timezoneOffset = timezoneOffset
        }
    }
}

// MARK: - Additional Initializers

extension ISO_8601.DateTime {
    /// Create a date-time from seconds since epoch
    /// - Parameters:
    ///   - secondsSinceEpoch: Seconds since Unix epoch (UTC)
    ///   - nanoseconds: Nanoseconds component (0-999,999,999, default: 0)
    ///   - timezoneOffsetSeconds: Timezone offset in seconds (default: 0 for UTC)
    /// - Throws: `ISO_8601.Date.Error` if nanoseconds is out of range
    public init(
        secondsSinceEpoch: Int = 0,
        nanoseconds: Int = 0,
        timezoneOffsetSeconds: Int = 0
    ) throws(ISO_8601.Date.Error) {
        guard (0..<1_000_000_000).contains(nanoseconds) else {
            throw ISO_8601.Date.Error.invalidFractionalSecond(String(nanoseconds))
        }
        // Convert total nanoseconds to millisecond/microsecond/nanosecond components
        let millisecond = nanoseconds / 1_000_000
        let remaining = nanoseconds % 1_000_000
        let microsecond = remaining / 1000
        let nanosecond = remaining % 1000

        let baseTime = Time_Primitives.Time(secondsSinceEpoch: secondsSinceEpoch)
        let time = Time_Primitives.Time(
            year: baseTime.year,
            month: baseTime.month,
            day: baseTime.day,
            hour: baseTime.hour,
            minute: baseTime.minute,
            second: baseTime.second,
            millisecond: try! Time_Primitives.Time.Millisecond(millisecond),
            microsecond: try! Time_Primitives.Time.Microsecond(microsecond),
            nanosecond: try! Time_Primitives.Time.Nanosecond(nanosecond)
        )
        self.init(
            time: time,
            timezoneOffset: Time_Primitives.Time.Timezone.Offset(seconds: timezoneOffsetSeconds)
        )
    }

    /// Create a date-time without validation (internal use only)
    /// - Warning: Using this with invalid nanoseconds will create an invalid DateTime
    internal init(
        __unchecked: Void = (),
        secondsEpoch: Int,
        nanoseconds: Int = 0,
        timezoneOffsetSeconds: Int = 0
    ) {
        // Convert total nanoseconds to millisecond/microsecond/nanosecond components
        let millisecond = nanoseconds / 1_000_000
        let remaining = nanoseconds % 1_000_000
        let microsecond = remaining / 1000
        let nanosecond = remaining % 1000

        let baseTime = Time_Primitives.Time(secondsSinceEpoch: secondsEpoch)
        let time = Time_Primitives.Time(
            year: baseTime.year,
            month: baseTime.month,
            day: baseTime.day,
            hour: baseTime.hour,
            minute: baseTime.minute,
            second: baseTime.second,
            millisecond: try! Time_Primitives.Time.Millisecond(millisecond),
            microsecond: try! Time_Primitives.Time.Microsecond(microsecond),
            nanosecond: try! Time_Primitives.Time.Nanosecond(nanosecond)
        )
        self.init(
            time: time,
            timezoneOffset: Time_Primitives.Time.Timezone.Offset(seconds: timezoneOffsetSeconds)
        )
    }
}

// MARK: - Computed Properties

extension ISO_8601.DateTime {
    /// Nanoseconds component (computed property for compatibility)
    public var nanoseconds: Int {
        time.totalNanoseconds
    }
}

// MARK: - Nested Accessors

extension ISO_8601.DateTime {
    /// Access epoch-relative properties
    public var epoch: Epoch {
        Epoch(dateTime: self)
    }

    /// Access timezone-related properties
    public var timezone: Timezone {
        Timezone(dateTime: self)
    }
}

// MARK: - Comparable

extension ISO_8601.DateTime {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.epoch.seconds != rhs.epoch.seconds {
            return lhs.epoch.seconds < rhs.epoch.seconds
        }
        return lhs.nanoseconds < rhs.nanoseconds
    }
}

// MARK: - Equatable & Hashable

extension ISO_8601.DateTime {
    /// Two DateTimes are equal if they represent the same moment in time
    /// (same epoch seconds and nanoseconds), regardless of timezone offset
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.epoch.seconds == rhs.epoch.seconds && lhs.nanoseconds == rhs.nanoseconds
    }

    /// Hash based on the moment in time (seconds and nanoseconds), not timezone display
    public func hash(into hasher: inout Hasher) {
        hasher.combine(epoch.seconds)
        hasher.combine(nanoseconds)
    }
}

// MARK: - Calendar Initializer

extension ISO_8601.DateTime {
    /// Create a date-time from calendar date components with validation
    /// - Parameters:
    ///   - year: Year
    ///   - month: Month (1-12)
    ///   - day: Day (1-31, validated for month/year)
    ///   - hour: Hour (0-23)
    ///   - minute: Minute (0-59)
    ///   - second: Second (0-60, allowing leap second)
    ///   - nanoseconds: Nanoseconds (0-999,999,999, default: 0)
    ///   - timezoneOffsetSeconds: Timezone offset in seconds (default: 0 for UTC)
    /// - Throws: `ISO_8601.Date.Error` if any component is out of valid range
    ///
    /// Components are interpreted in UTC, then the timezone offset is applied for display.
    public init(
        year: Int,
        month: Int,  // 1-12
        day: Int,  // 1-31
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        nanoseconds: Int = 0,
        timezoneOffsetSeconds: Int = 0
    ) throws(ISO_8601.Date.Error) {
        // Convert total nanoseconds to millisecond/microsecond/nanosecond components
        let millisecond = nanoseconds / 1_000_000
        let remaining = nanoseconds % 1_000_000
        let microsecond = remaining / 1000
        let nanosecond = remaining % 1000

        // Create Time with validation
        let time: Time_Primitives.Time
        do {
            time = try Time_Primitives.Time(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                millisecond: millisecond,
                microsecond: microsecond,
                nanosecond: nanosecond
            )
        } catch {
            throw .invalidComponents(error)
        }

        self.init(
            time: time,
            timezoneOffset: Time_Primitives.Time.Timezone.Offset(seconds: timezoneOffsetSeconds)
        )
    }
}

// MARK: - Components Extraction

extension ISO_8601.DateTime {
    /// Extract calendar date components (Year-Month-Day)
    ///
    /// Components reflect the local time based on `timezone.offsetSeconds`.
    /// The same moment in time will have different components in different timezones.
    public var components: ISO_8601.Date.Components {
        .init(self)
    }
}

// MARK: - ISO 8601 Specific Properties

extension ISO_8601.DateTime {
    /// ISO weekday (1=Monday, 2=Tuesday, ..., 7=Sunday)
    ///
    /// Converts from Zeller's congruence (0=Sunday) to ISO 8601 numbering (1=Monday)
    public var isoWeekday: Int {
        let comp = components
        // Zeller's: 0=Sunday, 1=Monday, ..., 6=Saturday
        // ISO: 1=Monday, 2=Tuesday, ..., 7=Sunday
        return comp.weekday == 0 ? 7 : comp.weekday
    }

    /// Ordinal day of year (1-365 or 1-366 in leap years)
    ///
    /// This is the day number within the year, starting from 1 for January 1.
    public var ordinalDay: Int {
        let comp = components
        let monthDays = Time_Primitives.Time.Calendar.Gregorian.daysInMonths(year: comp.year)
        var days = comp.day
        for m in 0..<(comp.month - 1) {
            days += monthDays[m]
        }
        return days
    }

    /// ISO week-year (may differ from calendar year at boundaries)
    ///
    /// December 29-31 might belong to next year's week 1
    /// January 1-3 might belong to previous year's last week
    public var isoWeekYear: Int {
        let comp = components
        let week = isoWeek

        // If we're in week 1 but in December, the week-year is next year
        if comp.month == 12 && week == 1 {
            return comp.year + 1
        }

        // If we're in week 52/53 but in January, the week-year is previous year
        if comp.month == 1 && week >= 52 {
            return comp.year - 1
        }

        return comp.year
    }

    /// ISO week number (1-53)
    ///
    /// Week 1 is the first week containing the first Thursday of the year
    /// (equivalently, the week containing January 4th)
    public var isoWeek: Int {
        let comp = components

        // Find the Monday of the week containing this date
        // ISO weekday: 1=Monday, 7=Sunday
        let isoDay = isoWeekday
        let daysSinceMonday = isoDay - 1
        let currentTime = try! Time_Primitives.Time(
            year: comp.year,
            month: comp.month,
            day: comp.day,
            hour: 0,
            minute: 0,
            second: 0
        )
        let mondayOfWeek =
            currentTime.secondsSinceEpoch
            / Time_Primitives.Time.Calendar.Gregorian.TimeConstants.secondsPerDay
            - daysSinceMonday

        // Find January 4th of this year (which is always in week 1)
        let jan4Time = try! Time_Primitives.Time(
            year: comp.year,
            month: 1,
            day: 4,
            hour: 0,
            minute: 0,
            second: 0
        )
        let jan4 =
            jan4Time.secondsSinceEpoch
            / Time_Primitives.Time.Calendar.Gregorian.TimeConstants.secondsPerDay

        // Find the Monday of the week containing January 4th
        let jan4WeekdayEnum = jan4Time.weekday
        let jan4Weekday: Int
        switch jan4WeekdayEnum {
        case .sunday: jan4Weekday = 0
        case .monday: jan4Weekday = 1
        case .tuesday: jan4Weekday = 2
        case .wednesday: jan4Weekday = 3
        case .thursday: jan4Weekday = 4
        case .friday: jan4Weekday = 5
        case .saturday: jan4Weekday = 6
        }
        let jan4ISOWeekday = jan4Weekday == 0 ? 7 : jan4Weekday
        let jan4DaysSinceMonday = jan4ISOWeekday - 1
        let mondayOfWeek1 = jan4 - jan4DaysSinceMonday

        // Calculate week number
        let weekNumber = ((mondayOfWeek - mondayOfWeek1) / 7) + 1

        // Handle edge cases
        if weekNumber < 1 {
            // This date belongs to the last week of the previous year
            // Calculate the number of weeks in the previous year
            return Self.weeksInYear(comp.year - 1)
        } else if weekNumber > Self.weeksInYear(comp.year) {
            // This date belongs to week 1 of the next year
            return 1
        }

        return weekNumber
    }

    /// Calculate the number of weeks in a given ISO year
    internal static func weeksInYear(_ year: Int) -> Int {
        // A year has 53 weeks if:
        // - January 1 is a Thursday, OR
        // - January 1 is a Wednesday and it's a leap year

        let jan1Time = try! Time_Primitives.Time(
            year: year,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0
        )
        let jan1WeekdayEnum = jan1Time.weekday
        let jan1Weekday: Int
        switch jan1WeekdayEnum {
        case .sunday: jan1Weekday = 0
        case .monday: jan1Weekday = 1
        case .tuesday: jan1Weekday = 2
        case .wednesday: jan1Weekday = 3
        case .thursday: jan1Weekday = 4
        case .friday: jan1Weekday = 5
        case .saturday: jan1Weekday = 6
        }
        let jan1ISOWeekday = jan1Weekday == 0 ? 7 : jan1Weekday

        if jan1ISOWeekday == 4 {  // Thursday
            return 53
        }

        // Wednesday and leap year
        if jan1ISOWeekday == 3 && Time_Primitives.Time.Calendar.Gregorian.isLeapYear(year) {
            return 53
        }

        return 52
    }
}

// MARK: - Codable

extension ISO_8601.DateTime: Codable {
    private enum CodingKeys: String, CodingKey {
        case secondsSinceEpoch
        case nanoseconds
        case timezoneOffsetSeconds
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let seconds = try container.decode(Int.self, forKey: .secondsSinceEpoch)
        let nanos = try container.decodeIfPresent(Int.self, forKey: .nanoseconds) ?? 0
        let offset = try container.decodeIfPresent(Int.self, forKey: .timezoneOffsetSeconds) ?? 0
        try self.init(secondsSinceEpoch: seconds, nanoseconds: nanos, timezoneOffsetSeconds: offset)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(epoch.seconds, forKey: .secondsSinceEpoch)
        if nanoseconds != 0 {
            try container.encode(nanoseconds, forKey: .nanoseconds)
        }
        try container.encode(timezone.offsetSeconds, forKey: .timezoneOffsetSeconds)
    }
}

// MARK: - CustomStringConvertible

extension ISO_8601.DateTime: CustomStringConvertible {
    public var description: String {
        Formatter.format(self)
    }
}
