import Byte
import Cursor

extension ISO_8601 {

    public struct RecurringInterval: Sendable, Equatable, Hashable {

        public let repetitions: Int?

        public let interval: Interval

        public init(repetitions: Int?, interval: Interval) throws(Error) {
            guard (repetitions ?? 0) >= 0 else { throw .negativeRepetitions(repetitions ?? 0) }
            self.repetitions = repetitions
            self.interval = interval
        }
    }
}

extension ISO_8601.RecurringInterval {

    public var isUnlimited: Bool {
        repetitions == nil
    }
}

extension ISO_8601.RecurringInterval: CustomStringConvertible {
    public var description: String {
        Formatter.format(self)
    }
}

extension ISO_8601.RecurringInterval: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = try ISO_8601.RecurringInterval(string)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension ISO_8601.RecurringInterval {

    public init(_ string: String) throws(ISO_8601.RecurringInterval.Parser.Error) {
        var input = [Byte](utf8: string)[...]
        let value = try ISO_8601.RecurringInterval.Parser<ArraySlice<Byte>>().parse(&input)
        guard input.isEmpty else { throw .unexpectedTrailingInput }
        self = value
    }
}
