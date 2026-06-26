//
//  ISO_8601.Parse.Digits.swift
//  swift-iso-8601
//
//  Fixed-width decimal digit parser for ISO 8601 date/time components.
//

public import Parser_Primitives
public import ASCII_Decimal_Parser_Primitives
public import Byte_Primitives

extension ISO_8601.Parse {
    /// Parses exactly `count` ASCII decimal digits into an Int.
    ///
    /// Unlike `ASCII.Decimal.Parser` which greedily consumes all digits,
    /// this parser consumes exactly the specified number, enabling fixed-width
    /// parsing of ISO 8601 components (e.g., 4-digit year, 2-digit month).
    ///
    /// Delegates to the L1 `ASCII.Decimal.Parser` with an `.exactly(count)`
    /// digit-count policy, which additionally rejects integer overflow that the
    /// historical hand-rolled accumulate loop silently wrapped — an accepted
    /// superset that is unreachable for the small fixed-width fields parsed here.
    public struct Digits<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
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
        do {
            return try ASCII.Decimal.Parser<Input, Int>(count: .exactly(count)).parse(&input)
        } catch {
            switch error {
            case .insufficientDigits: throw .expectedDigit
            case .noDigits: throw .expectedDigit
            case .overflow: throw .overflow
            case .invalidSign: throw .expectedDigit
            }
        }
    }
}
