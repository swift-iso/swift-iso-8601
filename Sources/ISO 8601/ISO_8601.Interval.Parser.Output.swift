//
//  ISO_8601.Interval.Parser.Output.swift
//  swift-iso-8601
//

extension ISO_8601.Interval.Parser {
    /// The parsed representation of an ISO 8601 time interval.
    public enum Output: Sendable, Equatable {
        /// An interval defined by explicit start and end date-times.
        case startEnd(
            start: ISO_8601.DateTime.Parser<Input>.Output,
            end: ISO_8601.DateTime.Parser<Input>.Output
        )
        /// An interval defined by a start date-time and a duration.
        case startDuration(
            start: ISO_8601.DateTime.Parser<Input>.Output,
            duration: ISO_8601.Duration.Parser<Input>.Output
        )
        /// An interval defined by a duration and an end date-time.
        case durationEnd(
            duration: ISO_8601.Duration.Parser<Input>.Output,
            end: ISO_8601.DateTime.Parser<Input>.Output
        )
        /// An interval defined by a duration alone.
        case duration(ISO_8601.Duration.Parser<Input>.Output)
    }
}
