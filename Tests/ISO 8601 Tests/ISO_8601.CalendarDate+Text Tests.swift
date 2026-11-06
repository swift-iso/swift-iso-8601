import ISO_8601
import Testing

@Suite struct `ISO_8601.CalendarDate+Text Tests` {
    @Test func `a date is YYYY-MM-DD on a day the calendar has`() {
        #expect(ISO_8601.CalendarDate(extended: "2092-02-29")?.extended == "2092-02-29")
        #expect(ISO_8601.CalendarDate(extended: "2091-02-29") == nil)
        #expect(ISO_8601.CalendarDate(extended: "2091-02-31") == nil)
        #expect(ISO_8601.CalendarDate(extended: "2091-13-01") == nil)
        #expect(ISO_8601.CalendarDate(extended: "x") == nil)
        #expect(ISO_8601.CalendarDate(extended: "") == nil)
        #expect(ISO_8601.CalendarDate(extended: "2091-3-1") == nil)
    }

    @Test func `a sign is not a digit`() {
        #expect(ISO_8601.CalendarDate(extended: "+091-03-01") == nil)
        #expect(ISO_8601.CalendarDate(extended: "2091-+3-01") == nil)
        #expect(ISO_8601.CalendarDate.Month(extended: "+091-03") == nil)
        #expect(ISO_8601.CalendarDate.Month(extended: "2091-+3") == nil)
        #expect(ISO_8601.CalendarDate.Reduced(extended: "+091-03-01") == nil)
    }

    @Test func `a month is YYYY-MM`() {
        #expect(ISO_8601.CalendarDate.Month(extended: "2026-01")?.extended == "2026-01")
        #expect(ISO_8601.CalendarDate.Month(extended: "2026-13") == nil)
    }

    @Test func `a reduced date keeps the precision it is known to, and its text`() {
        for (text, precision) in [
            ("2025-03-14", ISO_8601.CalendarDate.Reduced.Precision.day), ("2025-03", .month), ("2025", .year),
        ] {
            #expect(ISO_8601.CalendarDate.Reduced(extended: text)?.extended == text)
            #expect(ISO_8601.CalendarDate.Reduced(extended: text)?.precision == precision)
        }
        #expect(ISO_8601.CalendarDate.Reduced.Precision.month.rawValue == "month")
    }
}
