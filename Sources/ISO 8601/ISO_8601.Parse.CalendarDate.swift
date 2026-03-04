//
//  ISO_8601.Parse.CalendarDate.swift
//  swift-iso-8601
//
//  ISO 8601 calendar date: YYYY-MM-DD (extended) or YYYYMMDD (basic)
//

public import Parser_Primitives

extension ISO_8601.Parse {
    /// Parses an ISO 8601 calendar date.
    ///
    /// Extended format: `YYYY-MM-DD`
    /// Basic format: `YYYYMMDD`
    ///
    /// Validates month (1–12) and day (1–31) ranges.
    public struct CalendarDate<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.Parse.CalendarDate {
    public struct Output: Sendable, Equatable {
        public let year: Int
        public let month: Int
        public let day: Int

        @inlinable
        public init(year: Int, month: Int, day: Int) {
            self.year = year
            self.month = month
            self.day = day
        }
    }
}

extension ISO_8601.Parse.CalendarDate: Parser.`Protocol` {
    public typealias ParseOutput = Output
    public typealias Failure = ISO_8601.Parse.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let year = try ISO_8601.Parse.Digits<Input>(count: 4).parse(&input)

        // Detect extended format (hyphen separator)
        let extended: Bool
        if input.startIndex < input.endIndex && input[input.startIndex] == 0x2D {
            extended = true
            input = input[input.index(after: input.startIndex)...]
        } else {
            extended = false
        }

        let month = try ISO_8601.Parse.Digits<Input>(count: 2).parse(&input)
        guard month >= 1 && month <= 12 else { throw .invalidMonth(month) }

        if extended {
            guard input.startIndex < input.endIndex
                && input[input.startIndex] == 0x2D else {
                throw .expectedByte(0x2D)
            }
            input = input[input.index(after: input.startIndex)...]
        }

        let day = try ISO_8601.Parse.Digits<Input>(count: 2).parse(&input)
        guard day >= 1 && day <= 31 else { throw .invalidDay(day) }

        return Output(year: year, month: month, day: day)
    }
}
