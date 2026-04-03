//
//  ISO_8601.Interval.Parse.Error.swift
//  swift-iso-8601
//

extension ISO_8601.Interval.Parse {
    public enum Error: Swift.Error, Sendable, Equatable {
        case dateTimeError(ISO_8601.DateTime.Parse<Input>.Error)
        case durationError(ISO_8601.Duration.Parse<Input>.Error)
        case expectedSlash
        case twoDateTimes
        case twoDurations
    }
}
