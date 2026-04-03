//
//  ISO_8601.Parse.Error.swift
//  swift-iso-8601
//
//  Shared error type for ISO 8601 parser combinators.
//

extension ISO_8601.Parse {
    /// Errors shared across ISO 8601 parser combinators.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// A digit character was expected but not found.
        case expectedDigit
        /// The input ended before parsing was complete.
        case unexpectedEndOfInput
        /// A specific byte literal was expected but not found.
        case expectedByte(UInt8)
        /// A numeric value exceeded the representable range.
        case overflow
        /// The month value was outside the valid range (1-12).
        case invalidMonth(Int)
        /// The day value was outside the valid range for the given month.
        case invalidDay(Int)
        /// The hour value was outside the valid range (0-23).
        case invalidHour(Int)
        /// The minute value was outside the valid range (0-59).
        case invalidMinute(Int)
        /// The second value was outside the valid range (0-59).
        case invalidSecond(Int)
    }
}
