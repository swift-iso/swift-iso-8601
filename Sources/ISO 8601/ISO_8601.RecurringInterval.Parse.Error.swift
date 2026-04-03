//
//  ISO_8601.RecurringInterval.Parse.Error.swift
//  swift-iso-8601
//

extension ISO_8601.RecurringInterval.Parse {
    public enum Error: Swift.Error, Sendable, Equatable {
        case expectedR
        case expectedSlash
        case intervalError(ISO_8601.Interval.Parse<Input>.Error)
    }
}
