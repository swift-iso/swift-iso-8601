//
//  ISO_8601.__DurationParserError.swift
//  swift-iso-8601
//
//  Module-scope, non-generic error for the ISO 8601 duration parser.
//
//  Hoisted out of the generic `ISO_8601.Duration.Parser<Input>` namespace so the
//  `@error` SIL result carries no phantom `Input` type parameter — the structural
//  fix for the `FunctionSignatureOpts` release-build ICE
//  (`SILArgument.cpp:40 !type.hasTypeParameter()`; Research §A13 / swiftlang/swift#89617).
//  Surfaced through the public path `ISO_8601.Duration.Parser.Error` (a typealias).
//

/// Errors that can occur when parsing an ISO 8601 duration.
public enum __DurationParserError: Swift.Error, Sendable, Equatable {
    /// The input did not start with the required `P` designator.
    case expectedP
    /// The duration contained no date or time components after `P`.
    case emptyDuration
    /// A numeric value was not followed by a valid component designator.
    case expectedComponentDesignator
    /// A non-digit character was encountered where a digit was expected.
    case invalidDigit
    /// A numeric component value exceeded the representable range.
    ///
    /// Surfaced by the L1 `ASCII.Decimal.Parser`, which rejects integer
    /// overflow that the historical hand-rolled accumulate loop silently
    /// wrapped. Unreachable for the small component values of valid input.
    case overflow
    /// Parsing succeeded but the input was not fully consumed (trailing bytes).
    case unexpectedTrailingInput
}
