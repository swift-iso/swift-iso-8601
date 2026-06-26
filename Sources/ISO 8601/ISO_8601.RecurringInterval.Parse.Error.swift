//
//  ISO_8601.RecurringInterval.Parse.Error.swift
//  swift-iso-8601
//

extension ISO_8601.RecurringInterval.Parse {
    /// Errors that can occur when parsing an ISO 8601 recurring interval.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input did not start with the required `R` designator.
        case expectedR
        /// The input did not contain the required `/` separator after the repetition count.
        case expectedSlash
        /// The interval portion of the recurring interval was invalid.
        case intervalError(ISO_8601.Interval.Parse<Input>.Error)
        /// The repetition count exceeded the representable range.
        ///
        /// Surfaced by the L1 `ASCII.Decimal.Parser`, which rejects integer
        /// overflow that the historical hand-rolled accumulate loop silently
        /// wrapped. Unreachable for valid repetition counts.
        case overflow
    }
}
