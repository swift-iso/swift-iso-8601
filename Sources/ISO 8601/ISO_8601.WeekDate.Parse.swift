//
//  ISO_8601.WeekDate.Parse.swift
//  swift-iso-8601
//
//  ISO 8601 week date: YYYY-Www-d (extended) or YYYYWwwd (basic)
//

public import Parser_Primitives

extension ISO_8601.WeekDate {
    /// Parses an ISO 8601 week date.
    ///
    /// Extended format: `YYYY-Www-d`
    /// Basic format: `YYYYWwwd`
    ///
    /// - `W` (0x57) is the literal week designator
    /// - `ww` is the week number (01-53)
    /// - `d` is the weekday (1=Monday, 7=Sunday)
    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.WeekDate.Parse {
    public struct Output: Sendable, Equatable {
        public let weekYear: Int
        public let week: Int
        public let weekday: Int

        @inlinable
        public init(weekYear: Int, week: Int, weekday: Int) {
            self.weekYear = weekYear
            self.week = week
            self.weekday = weekday
        }
    }
}

extension ISO_8601.WeekDate.Parse: Parser.`Protocol` {
    public typealias ParseOutput = Output
    public typealias Failure = ISO_8601.Parse.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let weekYear = try ISO_8601.Parse.Digits<Input>(count: 4).parse(&input)

        // Detect extended format: '-' before 'W'
        let extended: Bool
        if input.startIndex < input.endIndex && input[input.startIndex] == 0x2D {
            extended = true
            input = input[input.index(after: input.startIndex)...]
        } else {
            extended = false
        }

        // Expect 'W' (0x57)
        guard input.startIndex < input.endIndex,
            input[input.startIndex] == 0x57
        else {
            throw .expectedByte(0x57)
        }
        input = input[input.index(after: input.startIndex)...]

        let week = try ISO_8601.Parse.Digits<Input>(count: 2).parse(&input)
        guard week >= 1 && week <= 53 else {
            throw .invalidMonth(week) // reuse for week range
        }

        if extended {
            guard input.startIndex < input.endIndex
                && input[input.startIndex] == 0x2D else {
                throw .expectedByte(0x2D)
            }
            input = input[input.index(after: input.startIndex)...]
        }

        let weekday = try ISO_8601.Parse.Digits<Input>(count: 1).parse(&input)
        guard weekday >= 1 && weekday <= 7 else {
            throw .invalidDay(weekday)
        }

        return Output(weekYear: weekYear, week: week, weekday: weekday)
    }
}
