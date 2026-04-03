//
//  ISO_8601.OrdinalDate.Parse.Output.swift
//  swift-iso-8601
//
//  ISO 8601 ordinal date parse output
//

extension ISO_8601.OrdinalDate.Parse {
    /// The parsed components of an ISO 8601 ordinal date.
    public struct Output: Sendable, Equatable {
        public let year: Int
        /// Day of the year (1-366).
        public let day: Int

        @inlinable
        public init(year: Int, day: Int) {
            self.year = year
            self.day = day
        }
    }
}
