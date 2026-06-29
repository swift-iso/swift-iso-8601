//
//  ISO_8601.Interval.Parser.swift
//  swift-iso-8601
//
//  ISO 8601 interval: start/end, start/duration, duration/end, or duration
//

public import Parser_Primitives
public import Byte_Primitives

extension ISO_8601.Interval {
    /// Parses an ISO 8601 interval.
    ///
    /// Four formats per ISO 8601:2019:
    /// - `<datetime>/<datetime>` -- start and end
    /// - `<datetime>/<duration>` -- start and duration
    /// - `<duration>/<datetime>` -- duration and end
    /// - `<duration>` -- duration only (no slash)
    ///
    /// The `/` separator (0x2F) splits the two components.
    /// A leading `P` (0x50) indicates a duration component.
    public struct Parser<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.Interval.Parser: Parser.`Protocol` {
    public typealias Failure = __IntervalParserError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> ISO_8601.Interval {
        guard input.startIndex < input.endIndex else {
            throw .dateTimeError(.expectedT)
        }

        // Check if first component is a duration (starts with 'P')
        if input[input.startIndex] == 0x50 {
            let duration: ISO_8601.Duration
            do {
                duration = try ISO_8601.Duration.Parser<Input>().parse(&input)
            } catch {
                throw .durationError(error)
            }

            // Check for '/' separator
            guard input.startIndex < input.endIndex else {
                return .duration(duration)
            }
            guard input[input.startIndex] == 0x2F else {
                return .duration(duration)
            }
            input = input[input.index(after: input.startIndex)...]

            // Second component must be a datetime
            let end: ISO_8601.DateTime
            do {
                end = try ISO_8601.DateTime.Parser<Input>().parse(&input)
            } catch {
                throw .dateTimeError(error)
            }
            return .durationEnd(duration: duration, end: end)
        }

        // First component is a datetime
        let start: ISO_8601.DateTime
        do {
            start = try ISO_8601.DateTime.Parser<Input>().parse(&input)
        } catch {
            throw .dateTimeError(error)
        }

        // Expect '/' separator
        guard input.startIndex < input.endIndex,
            input[input.startIndex] == 0x2F
        else {
            throw .expectedSlash
        }
        input = input[input.index(after: input.startIndex)...]

        // Check if second component is a duration
        guard input.startIndex < input.endIndex else {
            throw .dateTimeError(.expectedT)
        }

        if input[input.startIndex] == 0x50 {
            let duration: ISO_8601.Duration
            do {
                duration = try ISO_8601.Duration.Parser<Input>().parse(&input)
            } catch {
                throw .durationError(error)
            }
            return .startDuration(start: start, duration: duration)
        }

        // Second component is a datetime
        let end: ISO_8601.DateTime
        do {
            end = try ISO_8601.DateTime.Parser<Input>().parse(&input)
        } catch {
            throw .dateTimeError(error)
        }
        return .startEnd(start: start, end: end)
    }
}
