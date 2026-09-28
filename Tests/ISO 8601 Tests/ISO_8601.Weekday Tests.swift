import Foundation
import Testing

@testable import ISO_8601

@Suite
struct `ISO_8601.Weekday Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `ISO_8601.Weekday Tests`.Unit {

    @Test
    func `Calculate weekday for January 1, 2024 (Monday)`() throws {
        let weekday = try ISO_8601.CalendarDate(year: 2024, month: 1, day: 1).weekday

        #expect(weekday == .monday)
        #expect(weekday.isoNumber == 1)
        #expect(weekday.gregorianNumber == 1)
    }

    @Test
    func `Calculate weekday for January 15, 2024 (Monday)`() throws {
        let weekday = try ISO_8601.CalendarDate(year: 2024, month: 1, day: 15).weekday

        #expect(weekday == .monday)
    }

    @Test
    func `Calculate weekday for December 25, 2024 (Wednesday)`() throws {
        let weekday = try ISO_8601.CalendarDate(year: 2024, month: 12, day: 25).weekday

        #expect(weekday == .wednesday)
        #expect(weekday.isoNumber == 3)
        #expect(weekday.gregorianNumber == 3)
    }

    @Test
    func `Calculate weekday for January 1, 2000 (Saturday)`() throws {
        let weekday = try ISO_8601.CalendarDate(year: 2000, month: 1, day: 1).weekday

        #expect(weekday == .saturday)
        #expect(weekday.isoNumber == 6)
        #expect(weekday.gregorianNumber == 6)
    }

    @Test
    func `Calculate weekday for July 4, 1776 (Thursday)`() throws {
        let weekday = try ISO_8601.CalendarDate(year: 1776, month: 7, day: 4).weekday

        #expect(weekday == .thursday)
        #expect(weekday.isoNumber == 4)
    }

    @Test
    func `Calculate weekday for Sunday`() throws {

        let weekday = try ISO_8601.CalendarDate(year: 2024, month: 1, day: 7).weekday

        #expect(weekday == .sunday)
        #expect(weekday.isoNumber == 7)
        #expect(weekday.gregorianNumber == 0)
    }

    @Test
    func `ISO numbering for all days`() throws {
        let days: [(ISO_8601.Weekday, Int)] = [
            (.monday, 1),
            (.tuesday, 2),
            (.wednesday, 3),
            (.thursday, 4),
            (.friday, 5),
            (.saturday, 6),
            (.sunday, 7),
        ]

        for (day, expectedISO) in days {
            #expect(day.isoNumber == expectedISO)
        }
    }

    @Test
    func `Gregorian numbering for all days`() throws {
        let days: [(ISO_8601.Weekday, Int)] = [
            (.sunday, 0),
            (.monday, 1),
            (.tuesday, 2),
            (.wednesday, 3),
            (.thursday, 4),
            (.friday, 5),
            (.saturday, 6),
        ]

        for (day, expectedGregorian) in days {
            #expect(day.gregorianNumber == expectedGregorian)
        }
    }

    @Test
    func `Create from ISO number`() throws {
        #expect(ISO_8601.Weekday(isoNumber: 1) == .monday)
        #expect(ISO_8601.Weekday(isoNumber: 2) == .tuesday)
        #expect(ISO_8601.Weekday(isoNumber: 3) == .wednesday)
        #expect(ISO_8601.Weekday(isoNumber: 4) == .thursday)
        #expect(ISO_8601.Weekday(isoNumber: 5) == .friday)
        #expect(ISO_8601.Weekday(isoNumber: 6) == .saturday)
        #expect(ISO_8601.Weekday(isoNumber: 7) == .sunday)
    }

    @Test
    func `Create from Gregorian number`() throws {
        #expect(ISO_8601.Weekday(gregorianNumber: 0) == .sunday)
        #expect(ISO_8601.Weekday(gregorianNumber: 1) == .monday)
        #expect(ISO_8601.Weekday(gregorianNumber: 2) == .tuesday)
        #expect(ISO_8601.Weekday(gregorianNumber: 3) == .wednesday)
        #expect(ISO_8601.Weekday(gregorianNumber: 4) == .thursday)
        #expect(ISO_8601.Weekday(gregorianNumber: 5) == .friday)
        #expect(ISO_8601.Weekday(gregorianNumber: 6) == .saturday)
    }

    @Test
    func `All cases are available`() throws {
        let allDays = ISO_8601.Weekday.allCases

        #expect(allDays.count == 7)
        #expect(allDays.contains(.sunday))
        #expect(allDays.contains(.monday))
        #expect(allDays.contains(.tuesday))
        #expect(allDays.contains(.wednesday))
        #expect(allDays.contains(.thursday))
        #expect(allDays.contains(.friday))
        #expect(allDays.contains(.saturday))
    }

    @Test
    func `Round-trip between ISO and enum`() throws {
        for day in ISO_8601.Weekday.allCases {
            let iso = day.isoNumber
            let recovered = ISO_8601.Weekday(isoNumber: iso)
            #expect(recovered == day)
        }
    }

    @Test
    func `Round-trip between Gregorian and enum`() throws {
        for day in ISO_8601.Weekday.allCases {
            let gregorian = day.gregorianNumber
            let recovered = ISO_8601.Weekday(gregorianNumber: gregorian)
            #expect(recovered == day)
        }
    }
}

extension `ISO_8601.Weekday Tests`.`Edge Case` {

    @Test
    func `Reject invalid ISO number`() throws {
        #expect(ISO_8601.Weekday(isoNumber: 0) == nil)
        #expect(ISO_8601.Weekday(isoNumber: 8) == nil)
        #expect(ISO_8601.Weekday(isoNumber: -1) == nil)
    }

    @Test
    func `Reject invalid Gregorian number`() throws {
        #expect(ISO_8601.Weekday(gregorianNumber: 7) == nil)
        #expect(ISO_8601.Weekday(gregorianNumber: -1) == nil)
        #expect(ISO_8601.Weekday(gregorianNumber: 10) == nil)
    }

    @Test
    func `Calculate weekday for leap year February 29`() throws {

        let weekday = try ISO_8601.CalendarDate(year: 2024, month: 2, day: 29).weekday

        #expect(weekday == .thursday)
    }

    @Test
    func `Calculate weekday for year boundary`() throws {

        let weekday1 = try ISO_8601.CalendarDate(year: 2023, month: 12, day: 31).weekday
        #expect(weekday1 == .sunday)

        let weekday2 = try ISO_8601.CalendarDate(year: 2024, month: 1, day: 1).weekday
        #expect(weekday2 == .monday)
    }

    @Test
    func `Calculate weekday across centuries`() throws {

        let weekday1900 = try ISO_8601.CalendarDate(year: 1900, month: 1, day: 1).weekday
        #expect(weekday1900 == .monday)

        let weekday2000 = try ISO_8601.CalendarDate(year: 2000, month: 1, day: 1).weekday
        #expect(weekday2000 == .saturday)
    }
}

extension `ISO_8601.Weekday Tests`.Integration {

    @Test
    func `Weekday encodes to JSON`() throws {
        let weekday = ISO_8601.Weekday.monday
        let encoder = JSONEncoder()
        let data = try encoder.encode(weekday)
        let string = String(data: data, encoding: .utf8)

        #expect(string == "1")
    }

    @Test
    func `Weekday decodes from JSON`() throws {
        let json = Data("2".utf8)
        let decoder = JSONDecoder()
        let weekday = try decoder.decode(ISO_8601.Weekday.self, from: json)

        #expect(weekday == .tuesday)
    }

    @Test(arguments: -800...800)
    func `Weekday advances by one each day`(daysSinceUnixEpoch: Int) throws {
        let today = try ISO_8601.CalendarDate(daysSinceUnixEpoch: daysSinceUnixEpoch).weekday
        let tomorrow = try ISO_8601.CalendarDate(daysSinceUnixEpoch: daysSinceUnixEpoch + 1).weekday
        #expect(tomorrow.gregorianNumber == (today.gregorianNumber + 1) % 7)
    }
}
