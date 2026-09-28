import Byte
import Cursor

extension ISO_8601 {

    public struct Duration: Sendable, Hashable {

        public let years: Int

        public let months: Int

        public let days: Int

        public let hours: Int

        public let minutes: Int

        public let seconds: Int

        public let nanoseconds: Int

        public init(
            years: Int = 0,
            months: Int = 0,
            days: Int = 0,
            hours: Int = 0,
            minutes: Int = 0,
            seconds: Int = 0,
            nanoseconds: Int = 0
        ) throws(Error) {
            guard (0..<1_000_000_000).contains(nanoseconds) else {
                throw .nanosecondsOutOfRange(nanoseconds)
            }
            self.years = years
            self.months = months
            self.days = days
            self.hours = hours
            self.minutes = minutes
            self.seconds = seconds
            self.nanoseconds = nanoseconds
        }
    }
}

extension ISO_8601.Duration {

    public var isZero: Bool {
        [years, months, days, hours, minutes, seconds, nanoseconds].allSatisfy { $0 == 0 }
    }
}

extension ISO_8601.Duration: CustomStringConvertible {

    public var description: String {
        Formatter.format(self)
    }
}

extension ISO_8601.Duration: Codable {

    public init(from decoder: any Decoder) throws {
        self = try ISO_8601.Duration(try decoder.singleValueContainer().decode(String.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension ISO_8601.Duration {

    public init(_ string: String) throws(ISO_8601.Duration.Parser.Error) {
        var input = [Byte](utf8: string)[...]
        let value = try ISO_8601.Duration.Parser<ArraySlice<Byte>>().parse(&input)
        guard input.isEmpty else { throw .unexpectedTrailingInput }
        self = value
    }
}
