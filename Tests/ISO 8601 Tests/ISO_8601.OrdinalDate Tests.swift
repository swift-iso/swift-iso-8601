import Foundation
import Testing

@testable import ISO_8601

@Suite
struct `ISO_8601.OrdinalDate Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `ISO_8601.OrdinalDate Tests`.Unit {

    @Test
    func `Create ordinal date`() throws {
        let ordinal = try ISO_8601.OrdinalDate(year: 2024, day: 39)

        #expect(ordinal.year == 2024)
        #expect(ordinal.day == 39)
    }

    @Test
    func `Create ordinal date for January 1`() throws {
        let ordinal = try ISO_8601.OrdinalDate(year: 2024, day: 1)

        #expect(ordinal.day == 1)
    }

    @Test
    func `Create ordinal date for December 31 leap year`() throws {
        let ordinal = try ISO_8601.OrdinalDate(year: 2024, day: 366)

        #expect(ordinal.day == 366)
    }

    @Test
    func `Create ordinal date for December 31 common year`() throws {
        let ordinal = try ISO_8601.OrdinalDate(year: 2023, day: 365)

        #expect(ordinal.day == 365)
    }

    @Test
    func `Ordinal dates with same values are equal`() throws {
        let od1 = try ISO_8601.OrdinalDate(year: 2024, day: 39)
        let od2 = try ISO_8601.OrdinalDate(year: 2024, day: 39)

        #expect(od1 == od2)
    }

    @Test
    func `Ordinal dates with different values are not equal`() throws {
        let od1 = try ISO_8601.OrdinalDate(year: 2024, day: 39)
        let od2 = try ISO_8601.OrdinalDate(year: 2024, day: 40)

        #expect(od1 != od2)
    }
}

extension `ISO_8601.OrdinalDate Tests`.`Edge Case` {

    @Test
    func `Reject day 0`() throws {
        #expect(throws: ISO_8601.OrdinalDate.Error.self) {
            _ = try ISO_8601.OrdinalDate(year: 2024, day: 0)
        }
    }

    @Test
    func `Reject day 366 in common year`() throws {
        #expect(throws: ISO_8601.OrdinalDate.Error.self) {
            _ = try ISO_8601.OrdinalDate(year: 2023, day: 366)
        }
    }

    @Test
    func `Reject day 367 in leap year`() throws {
        #expect(throws: ISO_8601.OrdinalDate.Error.self) {
            _ = try ISO_8601.OrdinalDate(year: 2024, day: 367)
        }
    }
}

extension `ISO_8601.OrdinalDate Tests`.Integration {

    @Test
    func `Convert ordinal day 1 to datetime`() throws {
        let ordinal = try ISO_8601.OrdinalDate(year: 2024, day: 1)
        let dateTime = try ISO_8601.DateTime(date: ISO_8601.CalendarDate(ordinal))

        #expect(dateTime.date.year == 2024)
        #expect(dateTime.date.month == 1)
        #expect(dateTime.date.day == 1)
    }

    @Test
    func `Convert ordinal day 39 to datetime`() throws {
        let ordinal = try ISO_8601.OrdinalDate(year: 2024, day: 39)
        let dateTime = try ISO_8601.DateTime(date: ISO_8601.CalendarDate(ordinal))

        #expect(dateTime.date.year == 2024)
        #expect(dateTime.date.month == 2)
        #expect(dateTime.date.day == 8)
    }

    @Test
    func `Convert ordinal day 365 to datetime in common year`() throws {
        let ordinal = try ISO_8601.OrdinalDate(year: 2023, day: 365)
        let dateTime = try ISO_8601.DateTime(date: ISO_8601.CalendarDate(ordinal))

        #expect(dateTime.date.year == 2023)
        #expect(dateTime.date.month == 12)
        #expect(dateTime.date.day == 31)
    }

    @Test
    func `Convert ordinal day 366 to datetime in leap year`() throws {
        let ordinal = try ISO_8601.OrdinalDate(year: 2024, day: 366)
        let dateTime = try ISO_8601.DateTime(date: ISO_8601.CalendarDate(ordinal))

        #expect(dateTime.date.year == 2024)
        #expect(dateTime.date.month == 12)
        #expect(dateTime.date.day == 31)
    }

    @Test
    func `Round-trip datetime to ordinal date`() throws {
        let original = try ISO_8601.DateTime(year: 2024, month: 2, day: 8)
        let ordinal = ISO_8601.OrdinalDate(original.date)
        let converted = try ISO_8601.DateTime(date: ISO_8601.CalendarDate(ordinal))

        #expect(original.date.year == converted.date.year)
        #expect(original.date.month == converted.date.month)
        #expect(original.date.day == converted.date.day)
    }

    @Test(arguments: [1, 32, 60, 100, 200, 300, 365])
    func `Round-trip all days in year`(day: Int) throws {
        let ordinal = try ISO_8601.OrdinalDate(year: 2023, day: day)
        let dateTime = try ISO_8601.DateTime(date: ISO_8601.CalendarDate(ordinal))
        let roundTrip = ISO_8601.OrdinalDate(dateTime.date)

        #expect(roundTrip.year == ordinal.year, "Day \(day) - year")
        #expect(roundTrip.day == ordinal.day, "Day \(day) - day")
    }
}
