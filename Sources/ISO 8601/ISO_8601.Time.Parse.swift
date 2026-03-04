//
//  ISO_8601.Time.Parse.swift
//  swift-iso-8601
//
//  ISO 8601 time: HH:MM:SS (extended) or HHMMSS (basic) with optional fractional seconds
//

public import Parser_Primitives

extension ISO_8601.Time {
    /// Parses an ISO 8601 time of day.
    ///
    /// Extended format: `HH:MM:SS` or `HH:MM:SS.sss`
    /// Basic format: `HHMMSS` or `HHMMSS.sss`
    ///
    /// Supports both `.` and `,` as fractional second separator (ISO 8601 allows both).
    /// Fractional seconds are normalized to nanoseconds.
    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.Time.Parse {
    public struct Output: Sendable, Equatable {
        public let hour: Int
        public let minute: Int
        public let second: Int
        /// Fractional seconds as nanoseconds (0-999_999_999).
        public let nanoseconds: Int

        @inlinable
        public init(hour: Int, minute: Int, second: Int, nanoseconds: Int) {
            self.hour = hour
            self.minute = minute
            self.second = second
            self.nanoseconds = nanoseconds
        }
    }
}

extension ISO_8601.Time.Parse: Parser.`Protocol` {
    public typealias ParseOutput = Output
    public typealias Failure = ISO_8601.Parse.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let hour = try ISO_8601.Parse.Digits<Input>(count: 2).parse(&input)
        guard hour >= 0 && hour <= 24 else { throw .invalidHour(hour) }

        // Detect extended format (colon separator)
        let extended: Bool
        if input.startIndex < input.endIndex && input[input.startIndex] == 0x3A {
            extended = true
            input = input[input.index(after: input.startIndex)...]
        } else {
            extended = false
        }

        let minute = try ISO_8601.Parse.Digits<Input>(count: 2).parse(&input)
        guard minute >= 0 && minute <= 59 else { throw .invalidMinute(minute) }

        if extended {
            guard input.startIndex < input.endIndex
                && input[input.startIndex] == 0x3A else {
                throw .expectedByte(0x3A)
            }
            input = input[input.index(after: input.startIndex)...]
        }

        let second = try ISO_8601.Parse.Digits<Input>(count: 2).parse(&input)
        // 60 allowed for leap seconds
        guard second >= 0 && second <= 60 else { throw .invalidSecond(second) }

        // Optional fractional seconds (. or , followed by 1+ digits)
        var nanoseconds = 0
        if input.startIndex < input.endIndex {
            let sep = input[input.startIndex]
            if sep == 0x2E || sep == 0x2C {
                input = input[input.index(after: input.startIndex)...]
                var fraction = 0
                var digits = 0
                var index = input.startIndex
                while index < input.endIndex {
                    let byte = input[index]
                    guard byte >= 0x30 && byte <= 0x39 else { break }
                    if digits < 9 {
                        fraction = fraction &* 10 &+ Int(byte &- 0x30)
                    }
                    input.formIndex(after: &index)
                    digits += 1
                }
                input = input[index...]
                // Pad to 9 digits for nanoseconds
                while digits < 9 {
                    fraction = fraction &* 10
                    digits += 1
                }
                nanoseconds = fraction
            }
        }

        return Output(
            hour: hour, minute: minute,
            second: second, nanoseconds: nanoseconds
        )
    }
}
