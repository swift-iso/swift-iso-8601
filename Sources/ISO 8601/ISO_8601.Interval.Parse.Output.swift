//
//  ISO_8601.Interval.Parse.Output.swift
//  swift-iso-8601
//

extension ISO_8601.Interval.Parse {
    public enum Output: Sendable, Equatable {
        case startEnd(
            start: ISO_8601.DateTime.Parse<Input>.Output,
            end: ISO_8601.DateTime.Parse<Input>.Output
        )
        case startDuration(
            start: ISO_8601.DateTime.Parse<Input>.Output,
            duration: ISO_8601.Duration.Parse<Input>.Output
        )
        case durationEnd(
            duration: ISO_8601.Duration.Parse<Input>.Output,
            end: ISO_8601.DateTime.Parse<Input>.Output
        )
        case duration(ISO_8601.Duration.Parse<Input>.Output)
    }
}
