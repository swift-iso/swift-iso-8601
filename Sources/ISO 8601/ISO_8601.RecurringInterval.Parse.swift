//
//  ISO_8601.RecurringInterval.Parse.swift
//  swift-iso-8601
//
//  ISO 8601 recurring interval: R[n]/<interval>
//

public import Parser_Primitives

extension ISO_8601.RecurringInterval {
    /// Parses an ISO 8601 recurring interval.
    ///
    /// Format: `R[n]/<interval>`
    ///
    /// - `R` prefix (0x52) indicates recurring
    /// - Optional repetition count `n` (digits)
    /// - `/` separator (0x2F)
    /// - Interval body (parsed by `ISO_8601.Interval.Parse`)
    ///
    /// If `n` is omitted, repetitions are unlimited.
    ///
    /// Examples: `R5/2019-01-01T00:00:00Z/P1D`, `R/P1M`
    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.RecurringInterval.Parse {
    public struct Output: Sendable, Equatable {
        /// Repetition count, nil for unlimited.
        public let repetitions: Int?
        public let interval: ISO_8601.Interval.Parse<Input>.Output

        @inlinable
        public init(
            repetitions: Int?,
            interval: ISO_8601.Interval.Parse<Input>.Output
        ) {
            self.repetitions = repetitions
            self.interval = interval
        }
    }

    public enum Error: Swift.Error, Sendable, Equatable {
        case expectedR
        case expectedSlash
        case intervalError(ISO_8601.Interval.Parse<Input>.Error)
    }
}

extension ISO_8601.RecurringInterval.Parse: Parser.`Protocol` {
    public typealias Failure = ISO_8601.RecurringInterval.Parse<Input>.Error

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
                var value = 0
                while input.startIndex < input.endIndex {
                    let d = input[input.startIndex]
                    guard d >= 0x30 && d <= 0x39 else { break }
                    value = value &* 10 &+ Int(d &- 0x30)
                    input = input[input.index(after: input.startIndex)...]
                }
                repetitions = value
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
        let interval: ISO_8601.Interval.Parse<Input>.Output
        do {
            interval = try ISO_8601.Interval.Parse<Input>().parse(&input)
        } catch {
            throw .intervalError(error)
        }

        return Output(repetitions: repetitions, interval: interval)
    }
}
