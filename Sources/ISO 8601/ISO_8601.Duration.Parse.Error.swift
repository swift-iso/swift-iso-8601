//
//  ISO_8601.Duration.Parse.Error.swift
//  swift-iso-8601
//

extension ISO_8601.Duration.Parse {
    /// Errors that can occur when parsing an ISO 8601 duration.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input did not start with the required `P` designator.
        case expectedP
        /// The duration contained no date or time components after `P`.
        case emptyDuration
        /// A numeric value was not followed by a valid component designator.
        case expectedComponentDesignator
        /// A non-digit character was encountered where a digit was expected.
        case invalidDigit
    }
}
