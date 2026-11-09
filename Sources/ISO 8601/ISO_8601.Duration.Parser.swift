public import ASCII
public import Byte
public import Cursor
import Parser

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
        var hasTimeComponent = false
        var lastRank = -1
        while let code = input.upcoming(), code == .T || code.isDigit {
            if input.advance(past: .T) {
                guard !inTimePart else { throw .componentOutOfOrder }
                inTimePart = true
                continue
            }
            let value: Int
            do throws(ASCII.Decimal.Error) {
                value = try ASCII.Decimal.Parser<Input, Int>().parse(&input)
            } catch {
                throw error == .overflow ? .overflow : .invalidDigit
            }
            let fraction = input.nanosecondFraction()
            guard let designator = input.upcoming() else { throw .expectedComponentDesignator }
            _ = input.next()
            let rank: Int
            switch (inTimePart, designator) {
            case (false, .Y): (rank, fields.years) = (0, value)
            case (false, .M): (rank, fields.months) = (1, value)
            case (false, .D): (rank, fields.days) = (2, value)
            case (true, .H): (rank, fields.hours) = (3, value)
            case (true, .M): (rank, fields.minutes) = (4, value)
            case (true, .S): (rank, fields.seconds, fields.nanoseconds) = (5, value, fraction ?? 0)
            default: throw .expectedComponentDesignator
            }
            guard rank > lastRank else { throw .componentOutOfOrder }
            guard fraction == nil || rank == 5 else { throw .fractionNotOnSeconds }
            lastRank = rank
            hasComponent = true
            hasTimeComponent = inTimePart
        }
        guard hasComponent else { throw .emptyDuration }
        guard !inTimePart || hasTimeComponent else { throw .expectedComponentDesignator }
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
