//
//  ISO_8601.OrdinalDate.Parse.Output.swift
//  swift-iso-8601
//
//  ISO 8601 ordinal date parse output
//

extension ISO_8601.OrdinalDate.Parse {
    public struct Output: Sendable, Equatable {
        public let year: Int
        public let day: Int

        @inlinable
        public init(year: Int, day: Int) {
            self.year = year
            self.day = day
        }
    }
}
