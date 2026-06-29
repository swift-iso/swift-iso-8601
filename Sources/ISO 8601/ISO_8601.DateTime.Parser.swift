//
//  ISO_8601.DateTime.Parser.swift
//  swift-iso-8601
//
//  ISO 8601 date-time: Date "T" Time [Timezone]
//

public import Parser_Primitives
public import Byte_Primitives

extension ISO_8601.DateTime {
    /// Parses an ISO 8601 date-time.
    ///
    /// Format: `YYYY-MM-DD"T"HH:MM:SS[.sss][Z|+HH:MM]`
    ///
    /// Composes `CalendarDate`, `Time.Parse`, and optionally `Timezone.Offset.Parse`.
    /// The `T` separator (0x54) is required between date and time.
    ///
    /// Returns raw parsed components; construction of domain types is left
    /// to the caller.
    public struct Parser<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.DateTime.Parser: Parser.`Protocol` {
    public typealias Failure = ISO_8601.DateTime.Parser<Input>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        // Parse date
        let date: ISO_8601.CalendarDate.Parse<Input>.Output
        do {
            date = try ISO_8601.CalendarDate.Parse<Input>().parse(&input)
        } catch {
            throw .dateError(error)
        }

        // Expect 'T' (0x54)
        guard input.startIndex < input.endIndex,
            input[input.startIndex] == 0x54
        else {
            throw .expectedT
        }
        input = input[input.index(after: input.startIndex)...]

        // Parse time
        let time: ISO_8601.Time.Parse<Input>.Output
        do {
            time = try ISO_8601.Time.Parse<Input>().parse(&input)
        } catch {
            throw .timeError(error)
        }

        // Optionally parse timezone
        var timezone: ISO_8601.Timezone.Offset.Parse<Input>.Output? = nil
        if input.startIndex < input.endIndex {
            let byte = input[input.startIndex]
            // Z (0x5A), + (0x2B), - (0x2D) indicate timezone
            if byte == 0x5A || byte == 0x2B || byte == 0x2D {
                do {
                    timezone = try ISO_8601.Timezone.Offset.Parse<Input>().parse(&input)
                } catch {
                    throw .timezoneError(error)
                }
            }
        }

        return Output(date: date, time: time, timezone: timezone)
    }
}
