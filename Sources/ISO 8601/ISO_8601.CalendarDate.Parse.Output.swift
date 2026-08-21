extension ISO_8601.CalendarDate.Parse {

    public struct Output: Sendable, Equatable {
        public let year: Int
        public let month: Int
        public let day: Int

        @inlinable
        public init(year: Int, month: Int, day: Int) {
            self.year = year
            self.month = month
            self.day = day
        }
    }
}
