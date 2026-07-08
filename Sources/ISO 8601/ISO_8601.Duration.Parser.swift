//
//  ISO_8601.Duration.Parser.swift
//  swift-iso-8601
//
//  ISO 8601 duration: P[n]Y[n]M[n]DT[n]H[n]M[n]S
//

public import ASCII_Decimal_Parser_Primitives
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
    public struct Parser<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.Duration.Parser: Parser.`Protocol` {
    public typealias Failure = ISO_8601.Duration.Parser<Input>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> ISO_8601.Duration {
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

            // Accumulate integer value. The leading digit is guaranteed by the
            // guard above, so the L1 greedy parser's `.noDigits` is unreachable.
            // (It additionally rejects overflow the old wrapping loop ignored.)
            let value: Int
            do throws(ASCII.Decimal.Error) {
                value = try ASCII.Decimal.Parser<Input, Int>().parse(&input)
            } catch {
                switch error {
                case .overflow: throw .overflow
                // Unreachable under the leading-digit guard + greedy/`.none` policy;
                // remapped to the digit-error bucket for exhaustiveness.
                case .noDigits, .insufficientDigits, .invalidSign: throw .invalidDigit
                }
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
                            fraction = fraction &* 10 &+ Int(fb.underlying &- 0x30)
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
                case 0x48: hours = value  // H
                case 0x4D: minutes = value  // M
                case 0x53:  // S
                    seconds = value
                    nanoseconds = fracNanos
                default: throw .expectedComponentDesignator
                }
            } else {
                switch designator {
                case 0x59: years = value  // Y
                case 0x4D: months = value  // M
                case 0x44: days = value  // D
                default: throw .expectedComponentDesignator
                }
            }
        }

        guard hasComponent else { throw .emptyDuration }

        // Construct the domain value. The only failure mode is nanoseconds out
        // of range, which is unreachable here (the fractional scan caps at 9
        // significant digits ⇒ ≤ 999_999_999); mapped to the numeric bucket.
        do throws(ISO_8601.Date.Error) {
            return try ISO_8601.Duration(
                years: years,
                months: months,
                days: days,
                hours: hours,
                minutes: minutes,
                seconds: seconds,
                nanoseconds: nanoseconds
            )
        } catch {
            throw .overflow
        }
    }
}
