//
//  ISO_8601.Interval.Parse.swift
//  swift-iso-8601
//
//  ISO 8601 interval: start/end, start/duration, duration/end, or duration
//

public import Parser_Primitives

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
    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.Interval.Parse {
    public enum Output: Sendable, Equatable {
        case startEnd(
            start: ISO_8601.DateTime.Parse<Input>.Output,
            end: ISO_8601.DateTime.Parse<Input>.Output
        )
        case startDuration(
            start: ISO_8601.DateTime.Parse<Input>.Output,
            duration: ISO_8601.Duration.Parse<Input>.Output
        )
        case durationEnd(
            duration: ISO_8601.Duration.Parse<Input>.Output,
            end: ISO_8601.DateTime.Parse<Input>.Output
        )
        case duration(ISO_8601.Duration.Parse<Input>.Output)
    }

    public enum Error: Swift.Error, Sendable, Equatable {
        case dateTimeError(ISO_8601.DateTime.Parse<Input>.Error)
        case durationError(ISO_8601.Duration.Parse<Input>.Error)
        case expectedSlash
        case twoDateTimes
        case twoDurations
    }
}

extension ISO_8601.Interval.Parse: Parser.`Protocol` {
    public typealias ParseOutput = Output
    public typealias Failure = ISO_8601.Interval.Parse<Input>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        guard input.startIndex < input.endIndex else {
            throw .dateTimeError(.expectedT)
        }

        // Check if first component is a duration (starts with 'P')
        if input[input.startIndex] == 0x50 {
            let dur: ISO_8601.Duration.Parse<Input>.Output
            do {
                dur = try ISO_8601.Duration.Parse<Input>().parse(&input)
            } catch {
                throw .durationError(error)
            }

            // Check for '/' separator
            guard input.startIndex < input.endIndex else {
                return .duration(dur)
            }
            guard input[input.startIndex] == 0x2F else {
                return .duration(dur)
            }
            input = input[input.index(after: input.startIndex)...]

            // Second component must be a datetime
            let end: ISO_8601.DateTime.Parse<Input>.Output
            do {
                end = try ISO_8601.DateTime.Parse<Input>().parse(&input)
            } catch {
                throw .dateTimeError(error)
            }
            return .durationEnd(duration: dur, end: end)
        }

        // First component is a datetime
        let start: ISO_8601.DateTime.Parse<Input>.Output
        do {
            start = try ISO_8601.DateTime.Parse<Input>().parse(&input)
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
            let dur: ISO_8601.Duration.Parse<Input>.Output
            do {
                dur = try ISO_8601.Duration.Parse<Input>().parse(&input)
            } catch {
                throw .durationError(error)
            }
            return .startDuration(start: start, duration: dur)
        }

        // Second component is a datetime
        let end: ISO_8601.DateTime.Parse<Input>.Output
        do {
            end = try ISO_8601.DateTime.Parse<Input>().parse(&input)
        } catch {
            throw .dateTimeError(error)
        }
        return .startEnd(start: start, end: end)
    }
}
