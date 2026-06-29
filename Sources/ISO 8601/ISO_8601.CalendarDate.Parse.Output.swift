//
//  ISO_8601.CalendarDate.Parse.Output.swift
//  swift-iso-8601
//
//  ISO 8601 calendar date parse output
//

extension ISO_8601.CalendarDate.Parse {
    /// The parsed components of an ISO 8601 calendar date.
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
