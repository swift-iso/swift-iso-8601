//
//  ISO_8601.DateTime.Formatter Tests.swift
//  ISO 8601 Tests
//
//  Regression coverage for F-002 (fable-448): TimezoneFormat .utc must render
//  components derived from the epoch with a zero offset (the true UTC
//  instant), not the DateTime's own offset-shifted local components stamped
//  with a misleading 'Z'.
//

import Testing

@testable import ISO_8601

extension ISO_8601.DateTime.Formatter {
    @Suite struct Tests {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

// MARK: - Unit

extension ISO_8601.DateTime.Formatter.Tests.Unit {
    @Test
    func `UTC format renders the true UTC instant, not the offset-shifted local wall clock`()
        throws
    {
        let utcAnchor = try ISO_8601.DateTime("2024-01-15T10:30:00Z")
        let displayedAtPlusTwo = try ISO_8601.DateTime(
            secondsSinceEpoch: utcAnchor.epoch.seconds,
            timezoneOffsetSeconds: 7200  // +02:00
        )

        let formatted = ISO_8601.DateTime.Formatter.format(
            displayedAtPlusTwo,
            date: .calendar(extended: true),
            time: .time(extended: true),
            timezone: .utc
        )

        #expect(formatted == "2024-01-15T10:30:00Z")
    }

    @Test
    func `Offset format still renders local wall-clock components with the explicit suffix`()
        throws
    {
        let utcAnchor = try ISO_8601.DateTime("2024-01-15T10:30:00Z")
        let displayedAtPlusTwo = try ISO_8601.DateTime(
            secondsSinceEpoch: utcAnchor.epoch.seconds,
            timezoneOffsetSeconds: 7200  // +02:00
        )

        let formatted = ISO_8601.DateTime.Formatter.format(
            displayedAtPlusTwo,
            date: .calendar(extended: true),
            time: .time(extended: true),
            timezone: .offset(extended: true)
        )

        #expect(formatted == "2024-01-15T12:30:00+02:00")
    }
}

// MARK: - Edge Case: day-boundary crossing under UTC rendering

extension ISO_8601.DateTime.Formatter.Tests.`Edge Case` {
    @Test
    func `UTC format rolls the date across the day boundary when the offset requires it`()
        throws
    {
        // 23:15 UTC on the 15th, displayed at +03:00, reads as 02:15 local on
        // the 16th — but .utc rendering must show the true UTC day (15th),
        // not the offset-shifted local day (16th).
        let utcAnchor = try ISO_8601.DateTime("2024-01-15T23:15:00Z")
        let displayedAtPlusThree = try ISO_8601.DateTime(
            secondsSinceEpoch: utcAnchor.epoch.seconds,
            timezoneOffsetSeconds: 10800  // +03:00
        )

        let formatted = ISO_8601.DateTime.Formatter.format(
            displayedAtPlusThree,
            date: .calendar(extended: true),
            time: .time(extended: true),
            timezone: .utc
        )

        #expect(formatted == "2024-01-15T23:15:00Z")
    }

    @Test
    func `Offset format for the same instant still rolls forward to the local day`() throws {
        let utcAnchor = try ISO_8601.DateTime("2024-01-15T23:15:00Z")
        let displayedAtPlusThree = try ISO_8601.DateTime(
            secondsSinceEpoch: utcAnchor.epoch.seconds,
            timezoneOffsetSeconds: 10800  // +03:00
        )

        let formatted = ISO_8601.DateTime.Formatter.format(
            displayedAtPlusThree,
            date: .calendar(extended: true),
            time: .time(extended: true),
            timezone: .offset(extended: true)
        )

        #expect(formatted == "2024-01-16T02:15:00+03:00")
    }

    @Test
    func `Zero-offset DateTime is unaffected by the UTC-rendering fix`() throws {
        let dt = try ISO_8601.DateTime(
            year: 2024, month: 1, day: 15, hour: 12, minute: 30, second: 45
        )

        let formatted = ISO_8601.DateTime.Formatter.format(
            dt,
            date: .calendar(extended: true),
            time: .time(extended: true),
            timezone: .utc
        )

        #expect(formatted == "2024-01-15T12:30:45Z")
    }
}
