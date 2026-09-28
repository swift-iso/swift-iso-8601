import Testing
import Time

@testable import ISO_8601

@Suite
struct `ISO_8601.DateTime.Instant Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `ISO_8601.DateTime.Instant Tests`.Unit {

    @Test(
        arguments: [
            (text: "1970-01-01T00:00:00Z", seconds: 0 as Int64, nanoseconds: 0 as Int64),
            (text: "2024-02-29T12:34:56.789Z", seconds: 1_709_210_096, nanoseconds: 789_000_000),
            (text: "2024-02-29T07:34:56-05:00", seconds: 1_709_210_096, nanoseconds: 0),
            (text: "2024-02-28T21:04:56-15:30", seconds: 1_709_210_096, nanoseconds: 0),
            (text: "2000-03-01T00:00:00Z", seconds: 951_868_800, nanoseconds: 0),
            (text: "1969-07-20T20:17:40Z", seconds: -14_182_940, nanoseconds: 0),
            (text: "1969-12-31T23:59:59.5Z", seconds: -1, nanoseconds: 500_000_000),
            (text: "1969-12-31T18:59:59.5-05:00", seconds: -1, nanoseconds: 500_000_000),
            (text: "1900-01-01T00:00:00Z", seconds: -2_208_988_800, nanoseconds: 0),
            (text: "0000-01-01T00:00:00Z", seconds: -62_167_219_200, nanoseconds: 0),
            (text: "9999-12-31T23:59:59Z", seconds: 253_402_300_799, nanoseconds: 0),
        ]
    )
    func `Date-time maps to its instant and back`(text: String, seconds: Int64, nanoseconds: Int64) throws {
        let dateTime = try ISO_8601.DateTime(text)
        let instant = try Time.Instant(secondsSinceUnixEpoch: seconds, nanosecondFraction: Int32(nanoseconds))

        #expect(dateTime.instant == instant)

        let roundTrip = try ISO_8601.DateTime(instant, offset: dateTime.offset)
        #expect(roundTrip.date == dateTime.date)
        #expect(roundTrip.hour == dateTime.hour)
        #expect(roundTrip.minute == dateTime.minute)
        #expect(roundTrip.second == dateTime.second)
        #expect(roundTrip.nanoseconds == dateTime.nanoseconds)
        #expect(roundTrip.offset == dateTime.offset)
        #expect(roundTrip.instant == instant)
    }

    @Test
    func `Epoch is the first moment of 1970 in UTC`() throws {
        let epoch = try ISO_8601.DateTime(Time.Instant(secondsSinceUnixEpoch: 0))

        #expect(epoch.date == (try ISO_8601.CalendarDate(year: 1970, month: 1, day: 1)))
        #expect(epoch.hour == 0)
        #expect(epoch.offset == .utc)
        #expect(epoch.date.weekday == .thursday)
    }

    @Test
    func `Leap day maps to its wall clock under a negative offset`() throws {
        let instant = Time.Instant(secondsSinceUnixEpoch: 1_709_210_096)
        let dateTime = try ISO_8601.DateTime(instant, offset: .init(seconds: -5 * 3_600))

        #expect(dateTime.date == (try ISO_8601.CalendarDate(year: 2024, month: 2, day: 29)))
        #expect(dateTime.hour == 7)
        #expect(dateTime.minute == 34)
        #expect(dateTime.second == 56)
        #expect(dateTime.description == "2024-02-29T07:34:56-05:00")
    }

    @Test
    func `Negative offset crosses back into the previous day before 1970`() throws {
        let instant = Time.Instant(secondsSinceUnixEpoch: 0)
        let dateTime = try ISO_8601.DateTime(instant, offset: .init(seconds: -3_600))

        #expect(dateTime.date == (try ISO_8601.CalendarDate(year: 1969, month: 12, day: 31)))
        #expect(dateTime.hour == 23)
        #expect(dateTime == (try ISO_8601.DateTime(instant)))
    }
}

extension `ISO_8601.DateTime.Instant Tests`.`Edge Case` {


    @Test
    func `Instant whose local date passes year 9999 is rejected`() throws {
        let lastSecond = Time.Instant(secondsSinceUnixEpoch: 253_402_300_799)

        #expect(throws: ISO_8601.DateTime.Error.date(.daysSinceUnixEpochOutOfRange(2_932_897))) {
            _ = try ISO_8601.DateTime(lastSecond, offset: .init(seconds: 3_600))
        }
    }

    @Test(arguments: [
        (year: 1600, month: 2, day: 29),
        (year: 1900, month: 2, day: 28),
        (year: 2000, month: 2, day: 29),
        (year: 2100, month: 3, day: 1),
    ])
    func `Calendar date maps to days since the epoch and back`(year: Int, month: Int, day: Int) throws {
        let date = try ISO_8601.CalendarDate(year: year, month: month, day: day)

        #expect(try ISO_8601.CalendarDate(daysSinceUnixEpoch: date.daysSinceUnixEpoch) == date)
    }

    @Test
    func `Year 1900 has no leap day`() throws {
        #expect(throws: ISO_8601.CalendarDate.Error.dayOutOfRange(29, month: 2, year: 1900)) {
            _ = try ISO_8601.CalendarDate(year: 1900, month: 2, day: 29)
        }
    }
}
