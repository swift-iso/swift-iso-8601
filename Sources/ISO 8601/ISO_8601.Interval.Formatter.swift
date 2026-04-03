//
//  ISO_8601.Interval.Formatter.swift
//  swift-iso-8601
//
//  ISO 8601 interval formatter
//

extension ISO_8601.Interval {
    /// Formatter for ISO 8601 interval strings
    public enum Formatter {
        /// Format an interval as an ISO 8601 string
        ///
        /// - Parameter value: The interval to format
        /// - Returns: ISO 8601 interval string (e.g., "2019-08-27/2019-08-29")
        public static func format(_ value: ISO_8601.Interval) -> String {
            switch value {
            case .startEnd(let start, let end):
                let startStr = ISO_8601.DateTime.Formatter.format(start)
                let endStr = ISO_8601.DateTime.Formatter.format(end)
                return "\(startStr)/\(endStr)"

            case .duration(let duration):
                return duration.description

            case .startDuration(let start, let duration):
                let startStr = ISO_8601.DateTime.Formatter.format(start)
                let durationStr = duration.description
                return "\(startStr)/\(durationStr)"

            case .durationEnd(let duration, let end):
                let durationStr = duration.description
                let endStr = ISO_8601.DateTime.Formatter.format(end)
                return "\(durationStr)/\(endStr)"
            }
        }
    }
}
