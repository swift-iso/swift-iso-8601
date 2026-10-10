public import ASCII
public import Byte
public import Cursor
public import Parser

extension ISO_8601.CalendarDate {

    public struct Parse<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {

        @inlinable
        public init() {}
    }
}

extension ISO_8601.CalendarDate.Parse: Parsing {

    public typealias Failure = __ISO8601ParseError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let year = try ISO_8601.Digits<Input>(count: 4).parse(&input)
        let extended = input.advance(past: .hyphen)
        let month = try ISO_8601.Digits<Input>(count: 2).parse(&input)
        guard (1...12).contains(month) else { throw .invalidMonth(month) }
        guard !extended || input.advance(past: .hyphen) else { throw .expected(.hyphen) }
        let day = try ISO_8601.Digits<Input>(count: 2).parse(&input)
        guard (1...31).contains(day) else { throw .invalidDay(day) }
        return Output(year: year, month: month, day: day)
    }
}
