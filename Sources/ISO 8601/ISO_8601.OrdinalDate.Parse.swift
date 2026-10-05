public import ASCII
public import Byte
public import Cursor
public import Parser

extension ISO_8601.OrdinalDate {

    public struct Parse<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {

        @inlinable
        public init() {}
    }
}

extension ISO_8601.OrdinalDate.Parse: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Failure = __ISO8601ParseError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let year = try ISO_8601.Digits<Input>(count: 4).parse(&input)
        _ = input.advance(past: .hyphen)
        let day = try ISO_8601.Digits<Input>(count: 3).parse(&input)
        guard (1...366).contains(day) else { throw .invalidDay(day) }
        return Output(year: year, day: day)
    }
}
