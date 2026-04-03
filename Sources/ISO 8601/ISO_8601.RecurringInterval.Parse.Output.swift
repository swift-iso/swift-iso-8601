//
//  ISO_8601.RecurringInterval.Parse.Output.swift
//  swift-iso-8601
//

extension ISO_8601.RecurringInterval.Parse {
    public struct Output: Sendable, Equatable {
        /// Repetition count, nil for unlimited.
        public let repetitions: Int?
        public let interval: ISO_8601.Interval.Parse<Input>.Output

        @inlinable
        public init(
            repetitions: Int?,
            interval: ISO_8601.Interval.Parse<Input>.Output
        ) {
            self.repetitions = repetitions
            self.interval = interval
        }
    }
}
