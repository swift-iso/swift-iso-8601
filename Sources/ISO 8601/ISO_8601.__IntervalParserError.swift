//
//  ISO_8601.__IntervalParserError.swift
//  swift-iso-8601
//
//  Module-scope, non-generic error for the ISO 8601 interval parser.
//
//  Hoisted out of the generic `ISO_8601.Interval.Parse<Input>` namespace so the
//  `@error` SIL result carries no phantom `Input` type parameter — the structural
//  fix for the `FunctionSignatureOpts` release-build ICE
//  (`SILArgument.cpp:40 !type.hasTypeParameter()`; Research §A13 / swiftlang/swift#89617).
//  Composes the sibling domains' hoisted errors directly (no `<Input>`).
//  Surfaced through the public path `ISO_8601.Interval.Parser.Error` (a typealias).
//

/// Errors that can occur when parsing an ISO 8601 time interval.
public enum __IntervalParserError: Swift.Error, Sendable, Equatable {
    /// A date-time component of the interval was invalid.
    case dateTimeError(__DateTimeParserError)
    /// The duration component of the interval was invalid.
    case durationError(__DurationParserError)
    /// The input did not contain the required `/` separator.
    case expectedSlash
    /// Both sides of the interval were date-times; at least one must be a duration.
    case twoDateTimes
    /// Both sides of the interval were durations; at least one must be a date-time.
    case twoDurations
}
