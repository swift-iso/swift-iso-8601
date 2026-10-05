public import ASCII
public import Byte
public import Cursor
public import Parser

extension ISO_8601.Interval {

    public struct Parser<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {

        @inlinable
        public init() {}
    }
}

extension ISO_8601.Interval.Parser: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Failure = __IntervalParserError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> ISO_8601.Interval {
        guard input.upcoming() != nil else { throw .dateTimeError(.expectedT) }
        guard input.upcoming() != .P else {
            let duration = try Self.duration(&input)
            guard input.advance(past: .slash) else { return .duration(duration) }
            return .durationEnd(duration: duration, end: try Self.dateTime(&input))
        }
        let start = try Self.dateTime(&input)
        guard input.advance(past: .slash) else { throw .expectedSlash }
        guard input.upcoming() != nil else { throw .dateTimeError(.expectedT) }
        return if input.upcoming() == .P {
            .startDuration(start: start, duration: try Self.duration(&input))
        } else {
            .startEnd(start: start, end: try Self.dateTime(&input))
        }
    }
}

extension ISO_8601.Interval.Parser {

    @usableFromInline
    static func duration(_ input: inout Input) throws(Failure) -> ISO_8601.Duration {
        do throws(__DurationParserError) {
            return try ISO_8601.Duration.Parser<Input>().parse(&input)
        } catch {
            throw .durationError(error)
        }
    }

    @usableFromInline
    static func dateTime(_ input: inout Input) throws(Failure) -> ISO_8601.DateTime {
        do throws(__DateTimeParserError) {
            return try ISO_8601.DateTime.Parser<Input>().parse(&input)
        } catch {
            throw .dateTimeError(error)
        }
    }
}
