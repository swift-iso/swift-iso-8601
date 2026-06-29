//
//  ISO_8601.RecurringInterval.Parser.Error.swift
//  swift-iso-8601
//
//  Public-path alias onto the module-scope `__RecurringIntervalParserError`.
//  (Temporary on `Parse`; moves to `Parser` in the rename phase.)
//

extension ISO_8601.RecurringInterval.Parser {
    /// Errors that can occur when parsing an ISO 8601 recurring interval.
    public typealias Error = __RecurringIntervalParserError
}
