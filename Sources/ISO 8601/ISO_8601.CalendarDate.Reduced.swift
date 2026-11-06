extension ISO_8601.CalendarDate {

    /// A calendar date at the precision it is known to: ISO 8601's `YYYY-MM-DD`, or its reduced forms `YYYY-MM` and
    /// `YYYY`.
    public struct Reduced: Sendable, Hashable {

        public let year: Int

        public let month: Int?

        public let day: Int?

        private init(unchecked parts: (year: Int, month: Int?, day: Int?)) {
            self.year = parts.year
            self.month = parts.month
            self.day = parts.day
        }

        /// Fails when the parts name no date, month or year. A day needs a month.
        public init(year: Int, month: Int? = nil, day: Int? = nil) throws(ISO_8601.CalendarDate.Error) {
            guard let month else {
                guard ISO_8601.CalendarDate.years.contains(year) else { throw .yearOutOfRange(year) }
                if let day { throw .dayOutOfRange(day, month: 0, year: year) }
                self.init(unchecked: (year, nil, nil))
                return
            }
            guard let day else {
                self.init(try Month(year: year, month: month))
                return
            }
            self.init(try ISO_8601.CalendarDate(year: year, month: month, day: day))
        }

        public init(_ date: ISO_8601.CalendarDate) {
            self.init(unchecked: (date.year, date.month, date.day))
        }

        public init(_ month: Month) {
            self.init(unchecked: (month.year, month.month, nil))
        }
    }
}

extension ISO_8601.CalendarDate.Reduced {

    public enum Precision: String, Sendable, Hashable, CaseIterable, Codable {
        case day
        case month
        case year
    }

    public var precision: Precision {
        if day != nil { return .day }
        if month != nil { return .month }
        return .year
    }

    /// The full date, when this is known to the day.
    public var date: ISO_8601.CalendarDate? {
        guard let month, let day else { return nil }
        return ISO_8601.CalendarDate(unchecked: (year, month, day))
    }
}

extension ISO_8601.CalendarDate.Reduced {

    /// The date `YYYY-MM-DD`, `YYYY-MM` or `YYYY` spells, or `nil` when it spells none.
    public init?(extended text: some StringProtocol) {
        if let date = ISO_8601.CalendarDate(extended: text) {
            self.init(date)
        } else if let month = ISO_8601.CalendarDate.Month(extended: text) {
            self.init(month)
        } else if text.utf8.count == 4, text.utf8.allSatisfy({ (0x30...0x39).contains($0) }), let year = Int(text) {
            self.init(unchecked: (year, nil, nil))
        } else {
            return nil
        }
    }

    /// `YYYY-MM-DD`, `YYYY-MM` or `YYYY`.
    public var extended: String {
        var text = ISO_8601.CalendarDate.digits(year, 4)
        if let month { text += "-" + ISO_8601.CalendarDate.digits(month, 2) }
        if let day { text += "-" + ISO_8601.CalendarDate.digits(day, 2) }
        return text
    }
}

extension ISO_8601.CalendarDate.Reduced: Comparable {

    /// Chronological by what is known; a less precise date sorts before a more precise one it contains.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.year, lhs.month ?? 0, lhs.day ?? 0) < (rhs.year, rhs.month ?? 0, rhs.day ?? 0)
    }
}

extension ISO_8601.CalendarDate.Reduced: CustomStringConvertible {

    public var description: String { extended }
}

extension ISO_8601.CalendarDate.Reduced: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        guard let reduced = Self(extended: text) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "not an ISO 8601 calendar date: \(text)")
        }
        self = reduced
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(extended)
    }
}
