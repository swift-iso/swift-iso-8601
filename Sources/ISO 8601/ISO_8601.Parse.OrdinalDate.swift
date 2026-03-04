//
//  ISO_8601.Parse.OrdinalDate.swift
//  swift-iso-8601
//
//  ISO 8601 ordinal date: YYYY-DDD (extended) or YYYYDDD (basic)
//

public import Parser_Primitives

extension ISO_8601.Parse {
    /// Parses an ISO 8601 ordinal date.
    ///
    /// Extended format: `YYYY-DDD`
    /// Basic format: `YYYYDDD`
    ///
    /// - `DDD` is the ordinal day of the year (001–366)
    public struct OrdinalDate<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.Parse.OrdinalDate {
    public struct Output: Sendable, Equatable {
        public let year: Int
        public let day: Int

        @inlinable
        public init(year: Int, day: Int) {
            self.year = year
            self.day = day
        }
    }
}

extension ISO_8601.Parse.OrdinalDate: Parser.`Protocol` {
    public typealias ParseOutput = Output
    public typealias Failure = ISO_8601.Parse.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let year = try ISO_8601.Parse.Digits<Input>(count: 4).parse(&input)

        // Detect extended format
        if input.startIndex < input.endIndex && input[input.startIndex] == 0x2D {
            input = input[input.index(after: input.startIndex)...]
        }

        let day = try ISO_8601.Parse.Digits<Input>(count: 3).parse(&input)
        guard day >= 1 && day <= 366 else {
            throw .invalidDay(day)
        }

        return Output(year: year, day: day)
    }
}
