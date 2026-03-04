//
//  ISO_8601.DateTime.Parse.swift
//  swift-iso-8601
//
//  ISO 8601 date-time: Date "T" Time [Timezone]
//

public import Parser_Primitives

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
    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.DateTime.Parse {
    public struct Output: Sendable, Equatable {
        public let date: ISO_8601.Parse.CalendarDate<Input>.Output
        public let time: ISO_8601.Time.Parse<Input>.Output
        public let timezone: ISO_8601.Timezone.Offset.Parse<Input>.Output?

        @inlinable
        public init(
            date: ISO_8601.Parse.CalendarDate<Input>.Output,
            time: ISO_8601.Time.Parse<Input>.Output,
            timezone: ISO_8601.Timezone.Offset.Parse<Input>.Output?
        ) {
            self.date = date
            self.time = time
            self.timezone = timezone
        }
    }

    public enum Error: Swift.Error, Sendable, Equatable {
        case expectedT
        case dateError(ISO_8601.Parse.Error)
        case timeError(ISO_8601.Parse.Error)
        case timezoneError(ISO_8601.Parse.Error)
    }
}

extension ISO_8601.DateTime.Parse: Parser.`Protocol` {
    public typealias Failure = ISO_8601.DateTime.Parse<Input>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        // Parse date
        let date: ISO_8601.Parse.CalendarDate<Input>.Output
        do {
            date = try ISO_8601.Parse.CalendarDate<Input>().parse(&input)
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
