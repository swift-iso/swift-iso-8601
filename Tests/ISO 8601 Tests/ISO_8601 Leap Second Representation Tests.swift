import Testing

@testable import ISO_8601

@Suite
struct `Leap second representation` {

    @Test
    func `the raw time parser keeps second 60`() throws {
        let time = try ISO_8601.Time.Parser.parse("23:59:60")
        #expect(time.hour == 23)
        #expect(time.minute == 59)
        #expect(time.second == 60)
    }

    @Test
    func `the Unix-backed date-time initializer rejects second 60 at the 2016-12-31 leap second`() throws {
        let date = try ISO_8601.CalendarDate(year: 2016, month: 12, day: 31)
        #expect(throws: ISO_8601.DateTime.Error.secondOutOfRange(60)) {
            try ISO_8601.DateTime(date: date, hour: 23, minute: 59, second: 60)
        }
        _ = try ISO_8601.DateTime(date: date, hour: 23, minute: 59, second: 59)
    }

    @Test(arguments: ["2016-12-31T23:59:60Z", "2016-12-31T18:59:60-05:00"])
    func `the Unix-backed date-time parser rejects the 2016-12-31 leap second in any offset`(_ text: String) {
        #expect(throws: (any Error).self) {
            try ISO_8601.DateTime(text)
        }
    }

    @Test(arguments: ["2016-12-31T23:59:59Z", "2016-12-31T18:59:59-05:00"])
    func `the second before the leap second parses`(_ text: String) throws {
        _ = try ISO_8601.DateTime(text)
    }
}
