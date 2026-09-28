public import ASCII
public import Byte
public import Cursor
public import Parser

extension ISO_8601.Duration {

    public struct Parser<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {

        @inlinable
        public init() {}
    }
}

extension ISO_8601.Duration.Parser: Parsing {

    public typealias Failure = __DurationParserError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> ISO_8601.Duration {
        guard input.advance(past: .P) else { throw .expectedP }
        var fields = (years: 0, months: 0, days: 0, hours: 0, minutes: 0, seconds: 0, nanoseconds: 0)
        var inTimePart = false
        var hasComponent = false
        while let code = input.upcoming(), code == .T || code.isDigit {
            guard !input.advance(past: .T) else {
                inTimePart = true
                continue
            }
            let value: Int
            do throws(ASCII.Decimal.Error) {
                value = try ASCII.Decimal.Parser<Input, Int>().parse(&input)
            } catch {
                throw error == .overflow ? .overflow : .invalidDigit
            }
            let fraction = input.nanosecondFraction() ?? 0
            guard let designator = input.upcoming() else { throw .expectedComponentDesignator }
            _ = input.next()
            hasComponent = true
            switch (inTimePart, designator) {
            case (true, .H): fields.hours = value
            case (true, .M): fields.minutes = value
            case (true, .S): (fields.seconds, fields.nanoseconds) = (value, fraction)
            case (false, .Y): fields.years = value
            case (false, .M): fields.months = value
            case (false, .D): fields.days = value
            default: throw .expectedComponentDesignator
            }
        }
        guard hasComponent else { throw .emptyDuration }
        do throws(ISO_8601.Duration.Error) {
            return try ISO_8601.Duration(
                years: fields.years,
                months: fields.months,
                days: fields.days,
                hours: fields.hours,
                minutes: fields.minutes,
                seconds: fields.seconds,
                nanoseconds: fields.nanoseconds
            )
        } catch {
            throw .duration(error)
        }
    }
}
