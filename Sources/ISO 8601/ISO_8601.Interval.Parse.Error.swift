//
//  ISO_8601.Interval.Parse.Error.swift
//  swift-iso-8601
//
//  Public-path alias onto the module-scope `__IntervalParserError`.
//  (Temporary on `Parse`; moves to `Parser` in the rename phase.)
//

extension ISO_8601.Interval.Parse {
    /// Errors that can occur when parsing an ISO 8601 time interval.
    public typealias Error = __IntervalParserError
}
