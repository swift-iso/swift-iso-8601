//
//  ISO_8601.__RecurringIntervalParserError.swift
//  swift-iso-8601
//
//  Module-scope, non-generic error for the ISO 8601 recurring-interval parser.
//
//  Hoisted out of the generic `ISO_8601.RecurringInterval.Parser<Input>` namespace
//  so the `@error` SIL result carries no phantom `Input` type parameter — the
//  structural fix for the `FunctionSignatureOpts` release-build ICE
//  (`SILArgument.cpp:40 !type.hasTypeParameter()`; Research §A13 / swiftlang/swift#89617).
//  Surfaced through the public path `ISO_8601.RecurringInterval.Parser.Error` (a typealias).
//

/// Errors that can occur when parsing an ISO 8601 recurring interval.
public enum __RecurringIntervalParserError: Swift.Error, Sendable, Equatable {
    /// The input did not start with the required `R` designator.
    case expectedR
    /// The input did not contain the required `/` separator after the repetition count.
    case expectedSlash
    /// The interval portion of the recurring interval was invalid.
    case intervalError(__IntervalParserError)
    /// The repetition count exceeded the representable range.
    ///
    /// Surfaced by the L1 `ASCII.Decimal.Parser`, which rejects integer
    /// overflow that the historical hand-rolled accumulate loop silently
    /// wrapped. Unreachable for valid repetition counts.
    case overflow
    /// Parsing succeeded but the input was not fully consumed (trailing bytes).
    case unexpectedTrailingInput
}
