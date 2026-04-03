//
//  ISO_8601.Duration.Parse.Output.swift
//  swift-iso-8601
//

extension ISO_8601.Duration.Parse {
    public struct Output: Sendable, Equatable {
        public let years: Int
        public let months: Int
        public let days: Int
        public let hours: Int
        public let minutes: Int
        public let seconds: Int
        public let nanoseconds: Int

        @inlinable
        public init(
            years: Int, months: Int, days: Int,
            hours: Int, minutes: Int, seconds: Int,
            nanoseconds: Int
        ) {
            self.years = years
            self.months = months
            self.days = days
            self.hours = hours
            self.minutes = minutes
            self.seconds = seconds
            self.nanoseconds = nanoseconds
        }
    }
}
