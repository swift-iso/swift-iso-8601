//
//  ISO_8601.RecurringInterval.Parser.swift
//  swift-iso-8601
//
//  ISO 8601 recurring interval parser
//

// MARK: - Parsing

extension ISO_8601.RecurringInterval {
    /// Parser for ISO 8601 recurring interval strings
    public enum Parser {
        /// Parse an ISO 8601 recurring interval string
        ///
        /// - Parameter value: The R-format string (e.g., "R5/2019-01-01T00:00:00Z/P1D")
        /// - Returns: RecurringInterval instance
        /// - Throws: `ISO_8601.Date.Error` if parsing fails
        public static func parse(_ value: String) throws(ISO_8601.Date.Error) -> ISO_8601.RecurringInterval {
            guard value.hasPrefix("R") else {
                throw ISO_8601.Date.Error.invalidFormat("Recurring interval must start with 'R'")
            }

            let afterR = String(value.dropFirst())
            guard !afterR.isEmpty else {
                throw ISO_8601.Date.Error.invalidFormat("Recurring interval cannot be just 'R'")
            }

            // Split on first slash to separate repetitions from interval
            guard let firstSlash = afterR.firstIndex(of: "/") else {
                throw ISO_8601.Date.Error.invalidFormat(
                    "Recurring interval must contain '/' separator"
                )
            }

            let repsStr = String(afterR[..<firstSlash])
            let intervalStr = String(afterR[afterR.index(after: firstSlash)...])

            // Parse repetitions (empty means unlimited)
            let repetitions: Int?
            if repsStr.isEmpty {
                repetitions = nil
            } else {
                guard let reps = Int(repsStr) else {
                    throw ISO_8601.Date.Error.invalidFormat("Invalid repetition count: \(repsStr)")
                }
                guard reps >= 0 else {
                    throw ISO_8601.Date.Error.invalidFormat("Repetitions must be non-negative")
                }
                repetitions = reps
            }

            // Parse the interval
            let interval = try ISO_8601.Interval.Parser.parse(intervalStr)

            return try ISO_8601.RecurringInterval(repetitions: repetitions, interval: interval)
        }
    }
}
