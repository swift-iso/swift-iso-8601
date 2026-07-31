//
//  ISO_8601.DateTime.Formatter.TimezoneFormat.swift
//  swift-iso-8601
//
//  ISO 8601 date-time formatter timezone format options
//

extension ISO_8601.DateTime.Formatter {
    /// Timezone format options
    public enum TimezoneFormat {
        case none
        case utc  // Z
        case offset(extended: Bool)  // +05:30 or +0530
    }
}
