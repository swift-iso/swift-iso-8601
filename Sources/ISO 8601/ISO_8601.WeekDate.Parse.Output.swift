extension ISO_8601.WeekDate.Parse {

    public struct Output: Sendable, Equatable {

        public let weekYear: Int

        public let week: Int

        public let weekday: Int

        @inlinable
        public init(weekYear: Int, week: Int, weekday: Int) {
            self.weekYear = weekYear
            self.week = week
            self.weekday = weekday
        }
    }
}
