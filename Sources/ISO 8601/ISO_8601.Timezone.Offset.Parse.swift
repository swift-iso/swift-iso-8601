//
//  ISO_8601.Timezone.Offset.Parse.swift
//  swift-iso-8601
//
//  ISO 8601 timezone offset: Z, +HH:MM, -HH:MM, +HHMM, -HHMM, +HH, -HH
//

public import Parser_Primitives

extension ISO_8601.Timezone.Offset {
    /// Parses an ISO 8601 timezone designator.
    ///
    /// Formats:
    /// - `Z` -- UTC
    /// - `+HH:MM` or `-HH:MM` -- Extended offset
    /// - `+HHMM` or `-HHMM` -- Basic offset
    /// - `+HH` or `-HH` -- Hour-only offset
    ///
    /// Returns the offset from UTC in total seconds.
    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.Timezone.Offset.Parse {
    public struct Output: Sendable, Equatable {
        /// Offset from UTC in seconds. Zero for `Z`.
        public let totalSeconds: Int

        @inlinable
        public init(totalSeconds: Int) {
            self.totalSeconds = totalSeconds
        }
    }
}

extension ISO_8601.Timezone.Offset.Parse: Parser.`Protocol` {
    public typealias ParseOutput = Output
    public typealias Failure = ISO_8601.Parse.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        guard input.startIndex < input.endIndex else {
            throw .unexpectedEndOfInput
        }

        let first = input[input.startIndex]

        // Z = UTC
        if first == 0x5A {
            input = input[input.index(after: input.startIndex)...]
            return Output(totalSeconds: 0)
        }

        // + or -
        let sign: Int
        if first == 0x2B {
            sign = 1
        } else if first == 0x2D {
            sign = -1
        } else {
            throw .expectedByte(0x5A)
        }
        input = input[input.index(after: input.startIndex)...]

        let hour = try ISO_8601.Parse.Digits<Input>(count: 2).parse(&input)

        // Optional minute (with or without colon)
        var minute = 0
        if input.startIndex < input.endIndex {
            let next = input[input.startIndex]
            if next == 0x3A {
                input = input[input.index(after: input.startIndex)...]
                minute = try ISO_8601.Parse.Digits<Input>(count: 2).parse(&input)
            } else if next >= 0x30 && next <= 0x39 {
                minute = try ISO_8601.Parse.Digits<Input>(count: 2).parse(&input)
            }
        }

        return Output(totalSeconds: sign * (hour * 3600 + minute * 60))
    }
}
