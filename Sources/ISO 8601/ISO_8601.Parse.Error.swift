//
//  ISO_8601.Parse.Error.swift
//  swift-iso-8601
//
//  Shared error type for ISO 8601 parser combinators.
//

extension ISO_8601.Parse {
    public enum Error: Swift.Error, Sendable, Equatable {
        case expectedDigit
        case unexpectedEndOfInput
        case expectedByte(UInt8)
        case overflow
        case invalidMonth(Int)
        case invalidDay(Int)
        case invalidHour(Int)
        case invalidMinute(Int)
        case invalidSecond(Int)
    }
}
