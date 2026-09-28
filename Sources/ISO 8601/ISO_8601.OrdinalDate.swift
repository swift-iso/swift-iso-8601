extension ISO_8601 {

    public struct OrdinalDate: Sendable, Hashable {

        public let year: Int

        public let day: Int

        public init(year: Int, day: Int) throws(Error) {
            guard ISO_8601.CalendarDate.years.contains(year) else { throw .yearOutOfRange(year) }
            guard (1...ISO_8601.CalendarDate.numberOfDays(inYear: year)).contains(day) else {
                throw .dayOutOfRange(day, year: year)
            }
            self.year = year
            self.day = day
        }

        public init(_ date: ISO_8601.CalendarDate) {
            self.year = date.year
            self.day = date.ordinalDay
        }
    }
}
