//
//  ISO_8601.Time.Formatter.Format.swift
//  swift-iso-8601
//
//  ISO 8601 time formatter format options
//

extension ISO_8601.Time.Formatter {
    /// Separator style for formatted time strings.
    public enum Format: Sendable, Equatable {
        /// Colon-separated components (e.g. "12:30:45").
        case extended
        /// Contiguous digits with no separators (e.g. "123045").
        case basic
    }
}
