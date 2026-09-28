import Foundation
import Testing
import Time

@testable import ISO_8601

@Suite
struct `ISO_8601.DateTime Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `ISO_8601.DateTime Tests`.Unit {

    @Test
    func `Create from seconds since epoch`() throws {
        let dateTime = try ISO_8601.DateTime(Time.Instant(secondsSinceUnixEpoch: 1_609_459_200))
        #expect(dateTime.instant == Time.Instant(secondsSinceUnixEpoch: 1_609_459_200))
        #expect(dateTime.offset.seconds == 0)
    }

    @Test
    func `Create from epoch with timezone offset`() throws {
        let dateTime = try ISO_8601.DateTime(Time.Instant(secondsSinceUnixEpoch: 1_609_459_200), offset: .init(seconds: 3600))
        #expect(dateTime.instant == Time.Instant(secondsSinceUnixEpoch: 1_609_459_200))
        #expect(dateTime.offset.seconds == 3600)
    }

    @Test
    func `Create from date components`() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 45
        )

        #expect(dateTime.date.year == 2024)
        #expect(dateTime.date.month == 1)
        #expect(dateTime.date.day == 15)
        #expect(dateTime.hour == 12)
        #expect(dateTime.minute == 30)
        #expect(dateTime.second == 45)
    }

    @Test
    func `Create from components with timezone offset`() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            offset: .init(seconds: 3600)
        )

        #expect(dateTime.offset.seconds == 3600)
    }

    @Test
    func `Extract components from UTC datetime`() throws {
        let dateTime = try ISO_8601.DateTime(
            year: 2021,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0
        )

        #expect(dateTime.date.year == 2021)
        #expect(dateTime.date.month == 1)
        #expect(dateTime.date.day == 1)
        #expect(dateTime.hour == 0)
        #expect(dateTime.minute == 0)
        #expect(dateTime.second == 0)
    }

    @Test
    func `Components reflect timezone offset`() throws {

        let utcDateTime = try ISO_8601.DateTime(
            year: 2024,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            offset: .init(seconds: 0)
        )

        let offsetDateTime = try ISO_8601.DateTime(utcDateTime.instant, offset: .init(seconds: 10800))


        #expect(offsetDateTime.hour == 3)
    }

    @Test
    func `ISO weekday Monday is 1`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2024, month: 1, day: 1)
        #expect(dateTime.date.weekday.isoNumber == 1)
    }

    @Test
    func `ISO weekday Sunday is 7`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2024, month: 1, day: 7)
        #expect(dateTime.date.weekday.isoNumber == 7)
    }

    @Test
    func `Ordinal day for January 1`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2024, month: 1, day: 1)
        #expect(dateTime.date.ordinalDay == 1)
    }

    @Test
    func `Ordinal day for February 8`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2024, month: 2, day: 8)
        #expect(dateTime.date.ordinalDay == 39)
    }

    @Test
    func `Ordinal day for December 31 in common year`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2023, month: 12, day: 31)
        #expect(dateTime.date.ordinalDay == 365)
    }

    @Test
    func `Ordinal day for December 31 in leap year`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2024, month: 12, day: 31)
        #expect(dateTime.date.ordinalDay == 366)
    }

    @Test
    func `Week number for January 4 is always 1`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2024, month: 1, day: 4)
        #expect(ISO_8601.WeekDate(dateTime.date).week == 1)
    }

    @Test
    func `Week number increments correctly`() throws {
        let week2 = try ISO_8601.DateTime(year: 2024, month: 1, day: 15)
        #expect(ISO_8601.WeekDate(week2.date).week == 3)
    }

    @Test
    func `Week year matches calendar year for mid-year dates`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2024, month: 6, day: 15)
        #expect(ISO_8601.WeekDate(dateTime.date).weekYear == 2024)
    }

    @Test
    func `Equal datetimes have same epoch`() throws {
        let dt1 = try ISO_8601.DateTime(year: 2024, month: 1, day: 15)
        let dt2 = try ISO_8601.DateTime(year: 2024, month: 1, day: 15)

        #expect(dt1 == dt2)
    }

    @Test
    func `Timezone offset does not affect equality`() throws {
        let utc = try ISO_8601.DateTime(year: 2024, month: 1, day: 1, hour: 12)
        let offset = try ISO_8601.DateTime(utc.instant, offset: .init(seconds: 3600))

        #expect(utc == offset)
    }

    @Test
    func `DateTime comparison works`() throws {
        let earlier = try ISO_8601.DateTime(year: 2024, month: 1, day: 1)
        let later = try ISO_8601.DateTime(year: 2024, month: 1, day: 2)

        #expect(earlier < later)
        #expect(later > earlier)
    }
}

extension `ISO_8601.DateTime Tests`.`Edge Case` {

    @Test
    func `Rejects invalid month`() throws {
        #expect(throws: ISO_8601.DateTime.Error.date(.monthOutOfRange(13))) {
            _ = try ISO_8601.DateTime(year: 2024, month: 13, day: 1)
        }
    }

    @Test
    func `Rejects invalid day`() throws {
        #expect(throws: ISO_8601.DateTime.Error.self) {
            _ = try ISO_8601.DateTime(year: 2024, month: 2, day: 30)
        }
    }

    @Test
    func `Rejects invalid hour`() throws {
        #expect(throws: ISO_8601.DateTime.Error.self) {
            _ = try ISO_8601.DateTime(year: 2024, month: 1, day: 1, hour: 24)
        }
    }

    @Test
    func `Accepts February 29 in leap year`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2024, month: 2, day: 29)
        #expect(dateTime.date.day == 29)
    }

    @Test
    func `Rejects February 29 in common year`() throws {
        #expect(throws: ISO_8601.DateTime.Error.self) {
            _ = try ISO_8601.DateTime(year: 2023, month: 2, day: 29)
        }
    }
}

extension `ISO_8601.DateTime Tests`.Integration {

    @Test
    func `Convert to week date`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2024, month: 1, day: 15)
        let weekDate = ISO_8601.WeekDate(dateTime.date)

        #expect(weekDate.weekYear == 2024)
        #expect(weekDate.week > 0)
        #expect(weekDate.weekday >= 1 && weekDate.weekday <= 7)
    }

    @Test
    func `Convert to ordinal date`() throws {
        let dateTime = try ISO_8601.DateTime(year: 2024, month: 2, day: 8)
        let ordinal = ISO_8601.OrdinalDate(dateTime.date)

        #expect(ordinal.year == 2024)
        #expect(ordinal.day == 39)
    }
}
