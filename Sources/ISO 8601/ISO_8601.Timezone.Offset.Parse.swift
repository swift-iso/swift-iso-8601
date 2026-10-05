public import ASCII
public import Byte
public import Cursor
public import Parser

extension ISO_8601.Timezone.Offset {

    public struct Parse<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {

        @inlinable
        public init() {}
    }
}

extension ISO_8601.Timezone.Offset.Parse: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Failure = __ISO8601ParseError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        guard !input.advance(past: .Z) else { return Output(totalSeconds: 0) }
        let sign =
            if input.advance(past: .plus) { 1 } else if input.advance(past: .hyphen) { -1 } else {
                throw .expected(.Z)
            }
        let hour = try ISO_8601.Digits<Input>(count: 2).parse(&input)
        let minute =
            if input.advance(past: .colon) || input.upcoming()?.isDigit == true {
                try ISO_8601.Digits<Input>(count: 2).parse(&input)
            } else { 0 }
        guard minute <= 59 else { throw .invalidMinute(minute) }
        return Output(totalSeconds: sign * (hour * 3_600 + minute * 60))
    }
}
