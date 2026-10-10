public import ASCII
public import Byte
public import Cursor
public import Parser

extension ISO_8601.RecurringInterval {

    public struct Parser<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {

        @inlinable
        public init() {}
    }
}

extension ISO_8601.RecurringInterval.Parser: Parsing {

    public typealias Failure = __RecurringIntervalParserError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> ISO_8601.RecurringInterval {
        guard input.advance(past: .R) else { throw .expectedR }
        let repetitions = try Self.repetitions(&input)
        guard input.advance(past: .slash) else { throw .expectedSlash }
        let interval: ISO_8601.Interval
        do throws(__IntervalParserError) {
            interval = try ISO_8601.Interval.Parser<Input>().parse(&input)
        } catch {
            throw .intervalError(error)
        }
        do throws(ISO_8601.RecurringInterval.Error) {
            return try ISO_8601.RecurringInterval(repetitions: repetitions, interval: interval)
        } catch {
            throw .recurringInterval(error)
        }
    }
}

extension ISO_8601.RecurringInterval.Parser {

    @usableFromInline
    static func repetitions(_ input: inout Input) throws(Failure) -> Int? {
        guard input.upcoming()?.isDigit == true else { return nil }
        do throws(ASCII.Decimal.Error) {
            return try ASCII.Decimal.Parser<Input, Int>().parse(&input)
        } catch {
            throw error == .overflow ? .overflow : .expectedSlash
        }
    }
}
