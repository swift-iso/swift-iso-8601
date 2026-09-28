public import ASCII
public import Byte
public import Cursor
public import Parser

extension ISO_8601.WeekDate {

    public struct Parse<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {

        @inlinable
        public init() {}
    }
}

extension ISO_8601.WeekDate.Parse: Parsing {

    public typealias Failure = __ISO8601ParseError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let weekYear = try ISO_8601.Digits<Input>(count: 4).parse(&input)
        let extended = input.advance(past: .hyphen)
        guard input.advance(past: .W) else { throw .expected(.W) }
        let week = try ISO_8601.Digits<Input>(count: 2).parse(&input)
        guard (1...53).contains(week) else { throw .invalidWeek(week) }
        guard !extended || input.advance(past: .hyphen) else { throw .expected(.hyphen) }
        let weekday = try ISO_8601.Digits<Input>(count: 1).parse(&input)
        guard (1...7).contains(weekday) else { throw .invalidWeekday(weekday) }
        return Output(weekYear: weekYear, week: week, weekday: weekday)
    }
}
