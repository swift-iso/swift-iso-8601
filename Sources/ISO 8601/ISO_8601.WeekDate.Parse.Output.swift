//
//  ISO_8601.WeekDate.Parse.Output.swift
//  swift-iso-8601
//
//  ISO 8601 week date parse output
//

extension ISO_8601.WeekDate.Parse {
    /// The parsed components of an ISO 8601 week date.
    public struct Output: Sendable, Equatable {
        /// The ISO week-numbering year.
        public let weekYear: Int
        /// The ISO week number (1-53).
        public let week: Int
        /// The ISO weekday number (1=Monday, 7=Sunday).
        public let weekday: Int

        @inlinable
        public init(weekYear: Int, week: Int, weekday: Int) {
            self.weekYear = weekYear
            self.week = week
            self.weekday = weekday
        }
    }
}
