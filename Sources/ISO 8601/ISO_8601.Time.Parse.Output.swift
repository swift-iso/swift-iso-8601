//
//  ISO_8601.Time.Parse.Output.swift
//  swift-iso-8601
//
//  ISO 8601 time parse output
//

extension ISO_8601.Time.Parse {
    public struct Output: Sendable, Equatable {
        public let hour: Int
        public let minute: Int
        public let second: Int
        /// Fractional seconds as nanoseconds (0-999_999_999).
        public let nanoseconds: Int

        @inlinable
        public init(hour: Int, minute: Int, second: Int, nanoseconds: Int) {
            self.hour = hour
            self.minute = minute
            self.second = second
            self.nanoseconds = nanoseconds
        }
    }
}
