//
//  ISO_8601.RecurringInterval.Parser.swift
//  swift-iso-8601
//
//  ISO 8601 recurring interval: R[n]/<interval>
//

public import Parser_Primitives
public import ASCII_Decimal_Parser_Primitives
public import Byte_Primitives

extension ISO_8601.RecurringInterval {
    /// Parses an ISO 8601 recurring interval.
    ///
    /// Format: `R[n]/<interval>`
    ///
    /// - `R` prefix (0x52) indicates recurring
    /// - Optional repetition count `n` (digits)
    /// - `/` separator (0x2F)
    /// - Interval body (parsed by `ISO_8601.Interval.Parser`)
    ///
    /// If `n` is omitted, repetitions are unlimited.
    ///
    /// Examples: `R5/2019-01-01T00:00:00Z/P1D`, `R/P1M`
    public struct Parser<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.RecurringInterval.Parser: Parser.`Protocol` {
    public typealias Failure = ISO_8601.RecurringInterval.Parser<Input>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        // Expect 'R' (0x52)
        guard input.startIndex < input.endIndex,
            input[input.startIndex] == 0x52
        else {
            throw .expectedR
        }
        input = input[input.index(after: input.startIndex)...]

        // Parse optional repetition count (digits before '/')
        var repetitions: Int? = nil
        if input.startIndex < input.endIndex {
            let byte = input[input.startIndex]
            if byte >= 0x30 && byte <= 0x39 {
                // Leading digit guaranteed by the guard above, so the L1 greedy
                // parser's `.noDigits` is unreachable. (It additionally rejects
                // overflow the old wrapping loop ignored.)
                do {
                    repetitions = try ASCII.Decimal.Parser<Input, Int>().parse(&input)
                } catch {
                    switch error {
                    case .overflow: throw .overflow
                    // Unreachable under the leading-digit guard + greedy/`.none`
                    // policy; collapsed onto the next expected token for exhaustiveness.
                    case .noDigits, .insufficientDigits, .invalidSign: throw .expectedSlash
                    }
                }
            }
        }

        // Expect '/' (0x2F)
        guard input.startIndex < input.endIndex,
            input[input.startIndex] == 0x2F
        else {
            throw .expectedSlash
        }
        input = input[input.index(after: input.startIndex)...]

        // Parse interval
        let interval: ISO_8601.Interval.Parser<Input>.Output
        do {
            interval = try ISO_8601.Interval.Parser<Input>().parse(&input)
        } catch {
            throw .intervalError(error)
        }

        return Output(repetitions: repetitions, interval: interval)
    }
}
