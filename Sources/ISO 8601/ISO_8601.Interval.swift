//
//  ISO_8601.Interval.swift
//  swift-iso-8601
//
//  ISO 8601 Time Interval representation
//

extension ISO_8601 {
    /// ISO 8601 Time Interval representation
    ///
    /// Represents a time interval using one of four formats per ISO 8601:2019.
    ///
    /// ## Four Interval Formats
    ///
    /// 1. **Start and End**: `2019-08-27/2019-08-29`
    /// 2. **Duration Only**: `P3D`
    /// 3. **Start and Duration**: `2019-08-27/P3D`
    /// 4. **Duration and End**: `P3D/2019-08-29`
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Start and end
    /// let start = try ISO_8601.DateTime(year: 2019, month: 8, day: 27)
    /// let end = try ISO_8601.DateTime(year: 2019, month: 8, day: 29)
    /// let interval = ISO_8601.Interval.startEnd(start: start, end: end)
    ///
    /// // Start and duration
    /// let duration = try ISO_8601.Duration(days: 3)
    /// let interval2 = ISO_8601.Interval.startDuration(start: start, duration: duration)
    ///
    /// // Parse from string
    /// let parsed = try ISO_8601.Interval.Parser.parse("2019-08-27/P3D")
    /// ```
    public enum Interval: Sendable, Equatable, Hashable {
        /// Interval defined by start and end date-times
        case startEnd(start: DateTime, end: DateTime)

        /// Interval defined only by duration (no specific start/end)
        case duration(Duration)

        /// Interval defined by start and duration
        case startDuration(start: DateTime, duration: Duration)

        /// Interval defined by duration and end
        case durationEnd(duration: Duration, end: DateTime)
    }
}

// MARK: - Formatting

extension ISO_8601.Interval: CustomStringConvertible {
    public var description: String {
        Formatter.format(self)
    }
}

// MARK: - Codable

extension ISO_8601.Interval: Codable {
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

// MARK: - Helpers

extension ISO_8601.Interval {
    /// Check if this interval has a defined start
    public var hasStart: Bool {
        switch self {
        case .startEnd, .startDuration:
            return true
        case .duration, .durationEnd:
            return false
        }
    }

    /// Check if this interval has a defined end
    public var hasEnd: Bool {
        switch self {
        case .startEnd, .durationEnd:
            return true
        case .duration, .startDuration:
            return false
        }
    }

    /// Check if this interval has a defined duration
    public var hasDuration: Bool {
        switch self {
        case .duration, .startDuration, .durationEnd:
            return true
        case .startEnd:
            return false
        }
    }

    /// Get the start date-time if defined
    public var start: ISO_8601.DateTime? {
        switch self {
        case .startEnd(let start, _), .startDuration(let start, _):
            return start
        case .duration, .durationEnd:
            return nil
        }
    }

    /// Get the end date-time if defined
    public var end: ISO_8601.DateTime? {
        switch self {
        case .startEnd(_, let end), .durationEnd(_, let end):
            return end
        case .duration, .startDuration:
            return nil
        }
    }

    /// Get the duration if defined
    public var duration: ISO_8601.Duration? {
        switch self {
        case .duration(let dur), .startDuration(_, let dur), .durationEnd(let dur, _):
            return dur
        case .startEnd:
            return nil
        }
    }
}
