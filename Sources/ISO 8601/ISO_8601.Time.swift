extension ISO_8601 {

    public struct Time: Sendable, Hashable {

        public let hour: Int

        public let minute: Int?

        public let second: Int?

        public let nanoseconds: Int

        public let offset: Timezone.Offset?

        public init(
            hour: Int,
            minute: Int? = nil,
            second: Int? = nil,
            nanoseconds: Int = 0,
            offset: Timezone.Offset? = nil
        ) throws(Error) {
            guard (0...24).contains(hour) else { throw .hourOutOfRange(hour) }
            guard hour < 24 || (minute ?? 0, second ?? 0, nanoseconds) == (0, 0, 0) else {
                throw .invalidEndOfDay
            }
            guard (0...59).contains(minute ?? 0) else { throw .minuteOutOfRange(minute ?? 0) }
            guard (0...60).contains(second ?? 0) else { throw .secondOutOfRange(second ?? 0) }
            guard (0..<1_000_000_000).contains(nanoseconds) else {
                throw .nanosecondsOutOfRange(nanoseconds)
            }
            self.hour = hour
            self.minute = minute
            self.second = second
            self.nanoseconds = nanoseconds
            self.offset = offset
        }
    }
}

extension ISO_8601.Time: CustomStringConvertible {

    public var description: String {
        Formatter.format(self)
    }
}

extension ISO_8601.Time: Codable {

    public init(from decoder: any Decoder) throws {
        self = try Parser.parse(try decoder.singleValueContainer().decode(String.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
