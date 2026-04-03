//
//  ISO_8601.RecurringInterval.Formatter.swift
//  swift-iso-8601
//
//  ISO 8601 recurring interval formatter
//

extension ISO_8601.RecurringInterval {
    /// Formatter for ISO 8601 recurring interval strings
    public enum Formatter {
        /// Format a recurring interval as an ISO 8601 string
        ///
        /// - Parameter value: The recurring interval to format
        /// - Returns: ISO 8601 recurring interval string (e.g., "R5/2019-01-01T00:00:00Z/P1D")
        public static func format(_ value: ISO_8601.RecurringInterval) -> String {
            let prefix: String
            if let reps = value.repetitions {
                prefix = "R\(reps)"
            } else {
                prefix = "R"
            }

            let intervalStr = ISO_8601.Interval.Formatter.format(value.interval)
            return "\(prefix)/\(intervalStr)"
        }
    }
}
