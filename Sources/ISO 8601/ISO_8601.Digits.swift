//
//  ISO_8601.Digits.swift
//  swift-iso-8601
//
//  Fixed-width decimal digit parser for ISO 8601 date/time components.
//
//  Module-internal grammar helper (formerly ISO_8601.Parse.Digits; dropped from
//  the public surface when the ISO_8601.Parse namespace was dissolved). Marked
//  @usableFromInline so the @inlinable leaf parsers may compose it.
//

public import ASCII_Decimal_Parser_Primitives
public import Parser_Primitives

extension ISO_8601 {
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
    @usableFromInline
    struct Digits<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @usableFromInline
        let count: Int

        @inlinable
        package init(count: Int) {
            self.count = count
        }
    }
}

extension ISO_8601.Digits: Parser.`Protocol` {
    @usableFromInline
    typealias Output = Int
    @usableFromInline
    typealias Failure = __ISO8601ParseError

    @inlinable
    package func parse(_ input: inout Input) throws(Failure) -> Int {
        do throws(ASCII.Decimal.Error) {
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
