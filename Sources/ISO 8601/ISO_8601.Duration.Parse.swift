//
//  ISO_8601.Duration.Parse.swift
//  swift-iso-8601
//
//  ISO 8601 duration: P[n]Y[n]M[n]DT[n]H[n]M[n]S
//

public import Parser_Primitives

extension ISO_8601.Duration {
    /// Parses an ISO 8601 duration string.
    ///
    /// Format: `P[n]Y[n]M[n]DT[n]H[n]M[n]S`
    ///
    /// - `P` prefix indicates period/duration
    /// - `T` separates date components from time components
    /// - Components can be omitted if zero
    /// - Fractional seconds supported (`.` or `,` separator)
    ///
    /// Examples: `P3Y6M4DT12H30M5S`, `P1Y`, `PT5M`, `PT0.5S`
    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.Duration.Parse: Parser.`Protocol` {
    public typealias Failure = ISO_8601.Duration.Parse<Input>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        // Expect 'P' (0x50)
        guard input.startIndex < input.endIndex,
            input[input.startIndex] == 0x50
        else {
            throw .expectedP
        }
        input = input[input.index(after: input.startIndex)...]

        var years = 0
        var months = 0
        var days = 0
        var hours = 0
        var minutes = 0
        var seconds = 0
        var nanoseconds = 0
        var inTimePart = false
        var hasComponent = false

        while input.startIndex < input.endIndex {
            let byte = input[input.startIndex]

            // 'T' separator (0x54) switches to time components
            if byte == 0x54 {
                inTimePart = true
                input = input[input.index(after: input.startIndex)...]
                continue
            }

            // Must be a digit to start a number
            guard byte >= 0x30 && byte <= 0x39 else { break }

            // Accumulate integer value
            var value = 0
            while input.startIndex < input.endIndex {
                let d = input[input.startIndex]
                guard d >= 0x30 && d <= 0x39 else { break }
                value = value &* 10 &+ Int(d &- 0x30)
                input = input[input.index(after: input.startIndex)...]
            }

            // Check for fractional part (only valid before 'S')
            var fracNanos = 0
            if input.startIndex < input.endIndex {
                let sep = input[input.startIndex]
                if sep == 0x2E || sep == 0x2C {
                    input = input[input.index(after: input.startIndex)...]
                    var fraction = 0
                    var digits = 0
                    while input.startIndex < input.endIndex {
                        let fb = input[input.startIndex]
                        guard fb >= 0x30 && fb <= 0x39 else { break }
                        if digits < 9 {
                            fraction = fraction &* 10 &+ Int(fb &- 0x30)
                        }
                        input = input[input.index(after: input.startIndex)...]
                        digits += 1
                    }
                    while digits < 9 {
                        fraction = fraction &* 10
                        digits += 1
                    }
                    fracNanos = fraction
                }
            }

            // Read component designator
            guard input.startIndex < input.endIndex else {
                throw .expectedComponentDesignator
            }
            let designator = input[input.startIndex]
            input = input[input.index(after: input.startIndex)...]
            hasComponent = true

            if inTimePart {
                switch designator {
                case 0x48: hours = value    // H
                case 0x4D: minutes = value  // M
                case 0x53:                  // S
                    seconds = value
                    nanoseconds = fracNanos
                default: throw .expectedComponentDesignator
                }
            } else {
                switch designator {
                case 0x59: years = value    // Y
                case 0x4D: months = value   // M
                case 0x44: days = value     // D
                default: throw .expectedComponentDesignator
                }
            }
        }

        guard hasComponent else { throw .emptyDuration }

        return Output(
            years: years, months: months, days: days,
            hours: hours, minutes: minutes, seconds: seconds,
            nanoseconds: nanoseconds
        )
    }
}
