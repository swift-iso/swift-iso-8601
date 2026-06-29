//
//  ISO_8601.__DateTimeParserError.swift
//  swift-iso-8601
//
//  Module-scope, non-generic error for the ISO 8601 date-time parser.
//
//  Hoisted out of the generic `ISO_8601.DateTime.Parse<Input>` namespace so the
//  `@error` SIL result carries no phantom `Input` type parameter — the structural
//  fix for the `FunctionSignatureOpts` release-build ICE
//  (`SILArgument.cpp:40 !type.hasTypeParameter()`; Research §A13 / swiftlang/swift#89617).
//  Surfaced through the public path `ISO_8601.DateTime.Parser.Error` (a typealias).
//

/// Errors that can occur when parsing an ISO 8601 date-time.
public enum __DateTimeParserError: Swift.Error, Sendable, Equatable {
    /// The input did not contain the required `T` separator between date and time.
    case expectedT
    /// The date portion of the date-time was invalid.
    case dateError(__ISO8601ParseError)
    /// The time portion of the date-time was invalid.
    case timeError(__ISO8601ParseError)
    /// The timezone offset portion was invalid.
    case timezoneError(__ISO8601ParseError)
}
