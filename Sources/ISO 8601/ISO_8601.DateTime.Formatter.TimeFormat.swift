//
//  ISO_8601.DateTime.Formatter.TimeFormat.swift
//  swift-iso-8601
//
//  ISO 8601 date-time formatter time format options
//

extension ISO_8601.DateTime.Formatter {
    /// Time format options
    public enum TimeFormat {
        case none
        case time(extended: Bool)  // HH:MM:SS or HHMMSS
    }
}
