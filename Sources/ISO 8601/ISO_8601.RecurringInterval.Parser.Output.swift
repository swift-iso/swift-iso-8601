//
//  ISO_8601.RecurringInterval.Parser.Output.swift
//  swift-iso-8601
//

extension ISO_8601.RecurringInterval.Parser {
    /// The parsed components of an ISO 8601 recurring interval.
    public struct Output: Sendable, Equatable {
        /// Repetition count, nil for unlimited.
        public let repetitions: Int?
        public let interval: ISO_8601.Interval.Parser<Input>.Output

        @inlinable
        public init(
            repetitions: Int?,
            interval: ISO_8601.Interval.Parser<Input>.Output
        ) {
            self.repetitions = repetitions
            self.interval = interval
        }
    }
}
