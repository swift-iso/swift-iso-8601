//
//  ISO_8601.Duration.Parse.Error.swift
//  swift-iso-8601
//
//  Public-path alias onto the module-scope `__DurationParserError`.
//  (Temporary on `Parse`; moves to `Parser` in the rename phase.)
//

extension ISO_8601.Duration.Parse {
    /// Errors that can occur when parsing an ISO 8601 duration.
    public typealias Error = __DurationParserError
}
