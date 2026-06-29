//
//  ISO_8601.Time.Parse.swift
//  swift-iso-8601
//
//  ISO 8601 time: HH:MM[:SS] (extended) or HHMM[SS] (basic) with optional
//  fractional seconds. Seconds are optional (HH:MM / HHMM is valid).
//
//  Sub-grammar leaf consumed by ISO_8601.DateTime.Parser; the standalone
//  ISO_8601.Time string API (reduced precision, timezone) lives on
//  ISO_8601.Time.Parser.
//

public import Parser_Primitives
public import Byte_Primitives

extension ISO_8601.Time {
    /// Parses the time-of-day component of an ISO 8601 date-time.
    ///
    /// Extended format: `HH:MM`, `HH:MM:SS`, or `HH:MM:SS.sss`
    /// Basic format: `HHMM`, `HHMMSS`, or `HHMMSS.sss`
    ///
    /// Seconds are optional. Supports both `.` and `,` as the fractional-second
    /// separator (ISO 8601 allows both); fractional seconds normalize to
    /// nanoseconds. Hour 24 is accepted (the date-time parser rolls it over).
    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.Time.Parse: Parser.`Protocol` {
    public typealias Failure = __ISO8601ParseError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let hour = try ISO_8601.Digits<Input>(count: 2).parse(&input)
        guard hour >= 0 && hour <= 24 else { throw .invalidHour(hour) }

        // Detect extended format (colon separator)
        let extended: Bool
        if input.startIndex < input.endIndex && input[input.startIndex] == 0x3A {
            extended = true
            input = input[input.index(after: input.startIndex)...]
        } else {
            extended = false
        }

        let minute = try ISO_8601.Digits<Input>(count: 2).parse(&input)
        guard minute >= 0 && minute <= 59 else { throw .invalidMinute(minute) }

        // Optional seconds. Extended: introduced by a second ':'. Basic: present
        // iff the next byte is a digit (otherwise the time is reduced-precision
        // HH:MM / HHMM, e.g. "2024-01-15T12:30Z").
        let hasSeconds: Bool
        if extended {
            if input.startIndex < input.endIndex && input[input.startIndex] == 0x3A {
                input = input[input.index(after: input.startIndex)...]
                hasSeconds = true
            } else {
                hasSeconds = false
            }
        } else if input.startIndex < input.endIndex {
            let byte = input[input.startIndex]
            hasSeconds = byte >= 0x30 && byte <= 0x39
        } else {
            hasSeconds = false
        }

        var second = 0
        var nanoseconds = 0
        if hasSeconds {
            second = try ISO_8601.Digits<Input>(count: 2).parse(&input)
            // 60 allowed for leap seconds
            guard second >= 0 && second <= 60 else { throw .invalidSecond(second) }

            // Optional fractional seconds (. or , followed by 1+ digits)
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
                            fraction = fraction &* 10 &+ Int(byte.underlying &- 0x30)
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
        }

        return Output(
            hour: hour, minute: minute,
            second: second, nanoseconds: nanoseconds
        )
    }
}
