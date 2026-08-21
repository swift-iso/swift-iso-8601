import Foundation
import Testing

@testable import ISO_8601

extension ISO_8601.DateTime {
    @Suite struct Parsing {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_8601.DateTime.Parsing.Unit {
    @Test(
        arguments: [
            "2024-01-15T12:30:00+02:00",
            "2024-01-15T12:30:00-05:00",
            "2024-01-15T00:30:00+02:00",
            "2024-01-15T23:30:00-02:00",
            "2024-06-01T09:15:30+05:30",
            "1999-12-31T23:59:59+01:00",
        ]
    )
    func `Offset input parses to the same instant as Foundation`(string: String) throws {
        let dt = try ISO_8601.DateTime(string)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let foundationDate = try #require(formatter.date(from: string))

        #expect(dt.epoch.seconds == Int(foundationDate.timeIntervalSince1970))
    }
}

extension ISO_8601.DateTime.Parsing.`Edge Case` {
    @Test
    func `Positive offset shifts the instant earlier than the wall-clock reading`() throws {

        let dt = try ISO_8601.DateTime("2024-01-15T12:30:00+02:00")
        let utcOnly = try ISO_8601.DateTime("2024-01-15T10:30:00Z")

        #expect(dt.epoch.seconds == utcOnly.epoch.seconds)
        #expect(dt == utcOnly)
    }

    @Test
    func `Negative offset shifts the instant later than the wall-clock reading`() throws {

        let dt = try ISO_8601.DateTime("2024-01-15T12:30:00-05:00")
        let utcOnly = try ISO_8601.DateTime("2024-01-15T17:30:00Z")

        #expect(dt.epoch.seconds == utcOnly.epoch.seconds)
        #expect(dt == utcOnly)
    }

    @Test
    func `Offset input that crosses the UTC day boundary parses to the correct prior day`() throws {

        let dt = try ISO_8601.DateTime("2024-01-15T00:30:00+02:00")
        let expected = try ISO_8601.DateTime("2024-01-14T22:30:00Z")

        #expect(dt.epoch.seconds == expected.epoch.seconds)

        #expect(dt.components.day == 15)
        #expect(dt.components.hour == 0)
        #expect(dt.components.minute == 30)
    }

    @Test
    func `Offset input that crosses the UTC day boundary parses to the correct next day`() throws {

        let dt = try ISO_8601.DateTime("2024-01-15T23:30:00-02:00")
        let expected = try ISO_8601.DateTime("2024-01-16T01:30:00Z")

        #expect(dt.epoch.seconds == expected.epoch.seconds)
    }

    @Test
    func `Twenty-four-hundred rollover combines correctly with a UTC offset`() throws {

        let dt = try ISO_8601.DateTime("2024-01-15T24:00:00+02:00")
        let expected = try ISO_8601.DateTime("2024-01-15T22:00:00Z")

        #expect(dt.epoch.seconds == expected.epoch.seconds)
    }

    @Test
    func `Zero offset (explicit +00:00) matches Z`() throws {
        let plusZero = try ISO_8601.DateTime("2024-01-15T12:30:00+00:00")
        let zulu = try ISO_8601.DateTime("2024-01-15T12:30:00Z")

        #expect(plusZero.epoch.seconds == zulu.epoch.seconds)
    }
}
