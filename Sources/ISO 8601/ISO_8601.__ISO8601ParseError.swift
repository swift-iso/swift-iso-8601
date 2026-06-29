//
//  ISO_8601.__ISO8601ParseError.swift
//  swift-iso-8601
//
//  Module-scope, non-generic error shared by the ISO 8601 grammar-leaf parsers
//  (CalendarDate.Parse, WeekDate.Parse, OrdinalDate.Parse, Time.Parse,
//  Timezone.Offset.Parse) and the fixed-width Digits helper. Replaces the former
//  ISO_8601.Parse.Error; the ISO_8601.Parse namespace is dissolved (subjects own
//  their parsers; the shared error is hoisted to module scope per the package's
//  __<X>Error convention).
//

/// Errors shared across the ISO 8601 grammar-leaf parsers.
public enum __ISO8601ParseError: Swift.Error, Sendable, Equatable {
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
