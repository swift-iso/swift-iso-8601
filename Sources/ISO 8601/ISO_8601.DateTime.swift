import Byte
import Cursor
public import Time

extension ISO_8601 {

    public struct DateTime: Sendable {

        public let date: CalendarDate

        public let hour: Int

        public let minute: Int

        public let second: Int

        public let nanoseconds: Int

        public let offset: Timezone.Offset

        public init(
            date: CalendarDate,
            hour: Int = 0,
            minute: Int = 0,
            second: Int = 0,
            nanoseconds: Int = 0,
            offset: Timezone.Offset = .utc
        ) throws(Error) {
            guard (0...23).contains(hour) else { throw .hourOutOfRange(hour) }
            guard (0...59).contains(minute) else { throw .minuteOutOfRange(minute) }
            guard (0...59).contains(second) else { throw .secondOutOfRange(second) }
            guard (0..<1_000_000_000).contains(nanoseconds) else {
                throw .nanosecondsOutOfRange(nanoseconds)
            }
            self.date = date
            self.hour = hour
            self.minute = minute
            self.second = second
            self.nanoseconds = nanoseconds
            self.offset = offset
        }
    }
}

extension ISO_8601.DateTime {

    public init(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        nanoseconds: Int = 0,
        offset: ISO_8601.Timezone.Offset = .utc
    ) throws(Error) {
        let date: ISO_8601.CalendarDate
        do throws(ISO_8601.CalendarDate.Error) {
            date = try ISO_8601.CalendarDate(year: year, month: month, day: day)
        } catch {
            throw .date(error)
        }
        try self.init(
            date: date,
            hour: hour,
            minute: minute,
            second: second,
            nanoseconds: nanoseconds,
            offset: offset
        )
    }
}

extension ISO_8601.DateTime {

    public init(
        _ instant: Time::Time.Instant,
        offset: ISO_8601.Timezone.Offset = .utc
    ) throws(Error) {
        guard instant.offset.attoseconds.isMultiple(of: 1_000_000_000) else {
            throw .subnanosecondInstant
        }
        let local =
            instant.offset.attoseconds / 1_000_000_000
            + Int128(offset.seconds) * Self.nanosecondsPerSecond
        let nanosecondOfDay =
            (local % Self.nanosecondsPerDay + Self.nanosecondsPerDay) % Self.nanosecondsPerDay
        let secondOfDay = Int(nanosecondOfDay / Self.nanosecondsPerSecond)
        let date: ISO_8601.CalendarDate
        do throws(ISO_8601.CalendarDate.Error) {
            date = try ISO_8601.CalendarDate(
                daysSinceUnixEpoch: Int(clamping: (local - nanosecondOfDay) / Self.nanosecondsPerDay)
            )
        } catch {
            throw .date(error)
        }
        try self.init(
            date: date,
            hour: secondOfDay / 3_600,
            minute: secondOfDay % 3_600 / 60,
            second: secondOfDay % 60,
            nanoseconds: Int(nanosecondOfDay % Self.nanosecondsPerSecond),
            offset: offset
        )
    }

    public var instant: Time::Time.Instant {
        Time::Time.Instant(offset: Swift.Duration(attoseconds: nanosecondsSinceUnixEpoch * 1_000_000_000))
    }
}

extension ISO_8601.DateTime {

    static let nanosecondsPerSecond: Int128 = 1_000_000_000

    static let nanosecondsPerDay: Int128 = 86_400 * nanosecondsPerSecond

    var secondOfDay: Int {
        hour * 3_600 + minute * 60 + second
    }

    var nanosecondsSinceUnixEpoch: Int128 {
        (Int128(date.daysSinceUnixEpoch) * 86_400 + Int128(secondOfDay - offset.seconds))
            * Self.nanosecondsPerSecond
            + Int128(nanoseconds)
    }
}

extension ISO_8601.DateTime: Hashable, Comparable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.nanosecondsSinceUnixEpoch == rhs.nanosecondsSinceUnixEpoch
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.nanosecondsSinceUnixEpoch < rhs.nanosecondsSinceUnixEpoch
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(nanosecondsSinceUnixEpoch)
    }
}

extension ISO_8601.DateTime: CustomStringConvertible {

    public var description: String {
        Formatter.format(self, timezone: offset == .utc ? .utc : .offset(extended: true))
    }
}

extension ISO_8601.DateTime: Codable {

    public init(from decoder: any Decoder) throws {
        self = try ISO_8601.DateTime(try decoder.singleValueContainer().decode(String.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension ISO_8601.DateTime {

    public init(_ string: String) throws(ISO_8601.DateTime.Parser.Error) {
        var input = [Byte](utf8: string)[...]
        let value = try ISO_8601.DateTime.Parser<ArraySlice<Byte>>().parse(&input)
        guard input.isEmpty else { throw .unexpectedTrailingInput }
        self = value
    }
}
