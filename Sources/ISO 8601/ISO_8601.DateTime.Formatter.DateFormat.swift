//
//  ISO_8601.DateTime.Formatter.DateFormat.swift
//  swift-iso-8601
//
//  ISO 8601 date-time formatter date format options
//

extension ISO_8601.DateTime.Formatter {
    /// Date format options
    public enum DateFormat {
        case calendar(extended: Bool)  // YYYY-MM-DD or YYYYMMDD
        case week(extended: Bool)  // YYYY-Www-D or YYYYWwwD
        case ordinal(extended: Bool)  // YYYY-DDD or YYYYDDD
    }
}
