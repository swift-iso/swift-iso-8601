public import ASCII
public import Byte
public import Cursor
public import Parser

extension ISO_8601.Time {

    public struct Parse<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {

        @inlinable
        public init() {}
    }
}

extension ISO_8601.Time.Parse: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Failure = __ISO8601ParseError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let hour = try ISO_8601.Digits<Input>(count: 2).parse(&input)
        guard (0...24).contains(hour) else { throw .invalidHour(hour) }
        let extended = input.advance(past: .colon)
        let minute = try ISO_8601.Digits<Input>(count: 2).parse(&input)
        guard (0...59).contains(minute) else { throw .invalidMinute(minute) }
        let hasSeconds = extended ? input.advance(past: .colon) : input.upcoming()?.isDigit == true
        guard hasSeconds else { return Output(hour: hour, minute: minute, second: 0, nanoseconds: 0) }
        let second = try ISO_8601.Digits<Input>(count: 2).parse(&input)
        guard (0...60).contains(second) else { throw .invalidSecond(second) }
        return Output(
            hour: hour,
            minute: minute,
            second: second,
            nanoseconds: input.nanosecondFraction() ?? 0
        )
    }
}
