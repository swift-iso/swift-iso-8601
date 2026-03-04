//
//  ISO_8601.Parse.Digits.swift
//  swift-iso-8601
//
//  Fixed-width decimal digit parser for ISO 8601 date/time components.
//

public import Parser_Primitives

extension ISO_8601.Parse {
    /// Parses exactly `count` ASCII decimal digits into an Int.
    ///
    /// Unlike `Parser.ASCII.Integer.Decimal` which greedily consumes all digits,
    /// this parser consumes exactly the specified number, enabling fixed-width
    /// parsing of ISO 8601 components (e.g., 4-digit year, 2-digit month).
    public struct Digits<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        public let count: Int

        @inlinable
        public init(count: Int) {
            self.count = count
        }
    }
}

extension ISO_8601.Parse.Digits: Parser.`Protocol` {
    public typealias Output = Int
    public typealias Failure = ISO_8601.Parse.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Int {
        var result = 0
        var remaining = count
        var index = input.startIndex

        while remaining > 0 {
            guard index < input.endIndex else { throw .unexpectedEndOfInput }
            let byte = input[index]
            guard byte >= 0x30 && byte <= 0x39 else { throw .expectedDigit }
            result = result &* 10 &+ Int(byte &- 0x30)
            input.formIndex(after: &index)
            remaining -= 1
        }

        input = input[index...]
        return result
    }
}
