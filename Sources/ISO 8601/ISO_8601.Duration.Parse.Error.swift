//
//  ISO_8601.Duration.Parse.Error.swift
//  swift-iso-8601
//

extension ISO_8601.Duration.Parse {
    public enum Error: Swift.Error, Sendable, Equatable {
        case expectedP
        case emptyDuration
        case expectedComponentDesignator
        case invalidDigit
    }
}
