//
//  ISO_8601.DateTime.Parser.Error.swift
//  swift-iso-8601
//
//  Public-path alias onto the module-scope `__DateTimeParserError`.
//  (Temporary on `Parse`; moves to `Parser` in the rename phase.)
//

extension ISO_8601.DateTime.Parser {
    /// Errors that can occur when parsing an ISO 8601 date-time.
    public typealias Error = __DateTimeParserError
}
