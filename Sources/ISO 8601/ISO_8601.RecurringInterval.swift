//
//  ISO_8601.RecurringInterval.swift
//  swift-iso-8601
//
//  ISO 8601 Recurring Interval representation (R format)
//

import Byte_Parser_Primitives
import Parser_Primitives

extension ISO_8601 {
    /// ISO 8601 Recurring Interval representation
    ///
    /// Represents a repeating time interval using the R format per ISO 8601:2019.
    ///
    /// ## Format
    /// - `Rn/<interval>` where n is the number of repetitions
    /// - `R/<interval>` for unlimited repetitions
    ///
    /// ## Examples
    /// - `R5/2019-01-01T00:00:00Z/P1D` - 5 daily repetitions starting Jan 1, 2019
    /// - `R/2019-01-01T00:00:00Z/P1W` - Unlimited weekly repetitions
    /// - `R3/P1Y2M10DT2H30M/2019-12-31T23:59:59Z` - 3 repetitions ending Dec 31, 2019
    /// - `R12/P1M` - 12 monthly periods
    ///
    /// ```swift
    /// let start = try ISO_8601.DateTime(year: 2019, month: 1, day: 1)
    /// let duration = try ISO_8601.Duration(days: 1)
    /// let interval = ISO_8601.Interval.startDuration(start: start, duration: duration)
    /// let recurring = ISO_8601.RecurringInterval(repetitions: 5, interval: interval)
    ///
    /// let formatted = recurring.description  // "R5/2019-01-01T00:00:00Z/P1D"
    /// let parsed = try ISO_8601.RecurringInterval("R5/2019-01-01T00:00:00Z/P1D")
    /// ```
    public struct RecurringInterval: Sendable, Equatable, Hashable {
        /// Number of repetitions, nil for unlimited
        public let repetitions: Int?

        /// The interval to repeat
        public let interval: Interval

        /// Create a recurring interval
        ///
        /// - Parameters:
        ///   - repetitions: Number of repetitions (nil for unlimited)
        ///   - interval: The interval to repeat
        /// - Throws: `ISO_8601.Date.Error` if repetitions is negative
        public init(repetitions: Int?, interval: Interval) throws(ISO_8601.Date.Error) {
            if let reps = repetitions {
                guard reps >= 0 else {
                    throw ISO_8601.Date.Error.invalidFormat("Repetitions must be non-negative")
                }
            }
            self.repetitions = repetitions
            self.interval = interval
        }
    }
}

// MARK: - Unlimited Check

extension ISO_8601.RecurringInterval {
    /// Check if this recurring interval is unlimited
    public var isUnlimited: Bool {
        repetitions == nil
    }
}

// MARK: - Formatting

extension ISO_8601.RecurringInterval: CustomStringConvertible {
    public var description: String {
        Formatter.format(self)
    }
}

// MARK: - Codable

extension ISO_8601.RecurringInterval: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = try ISO_8601.RecurringInterval(string)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

// MARK: - String Parsing

extension ISO_8601.RecurringInterval {
    /// Parses an ISO 8601 recurring-interval string (`R[n]/<interval>`).
    ///
    /// - Parameter string: The ISO 8601 recurring-interval string
    ///   (e.g. `R5/2019-01-01T00:00:00Z/P1D`, `R/P1M`).
    /// - Throws: ``Parser/Error`` if the string is not a complete, valid
    ///   recurring interval.
    public init(_ string: String) throws(ISO_8601.RecurringInterval.Parser.Error) {
        var input = Byte.Input(utf8: string)
        let value = try ISO_8601.RecurringInterval.Parser<Byte.Input>().parse(&input)
        guard input.isEmpty else { throw .unexpectedTrailingInput }
        self = value
    }
}
