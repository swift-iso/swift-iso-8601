//
//  ISO_8601.Interval.Parse.Error.swift
//  swift-iso-8601
//

extension ISO_8601.Interval.Parse {
    /// Errors that can occur when parsing an ISO 8601 time interval.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// A date-time component of the interval was invalid.
        case dateTimeError(ISO_8601.DateTime.Parse<Input>.Error)
        /// The duration component of the interval was invalid.
        case durationError(ISO_8601.Duration.Parse<Input>.Error)
        /// The input did not contain the required `/` separator.
        case expectedSlash
        /// Both sides of the interval were date-times; at least one must be a duration.
        case twoDateTimes
        /// Both sides of the interval were durations; at least one must be a date-time.
        case twoDurations
    }
}
