extension ISO_8601.CalendarDate {

    /// A calendar month of a year, ISO 8601's reduced-precision `YYYY-MM`.
    public struct Month: Sendable, Hashable {

        public let year: Int

        public let month: Int

        public init(year: Int, month: Int) throws(ISO_8601.CalendarDate.Error) {
            guard ISO_8601.CalendarDate.years.contains(year) else { throw .yearOutOfRange(year) }
            guard (1...12).contains(month) else { throw .monthOutOfRange(month) }
            self.year = year
            self.month = month
        }

        /// The month `date` falls in.
        public init(_ date: ISO_8601.CalendarDate) {
            self.year = date.year
            self.month = date.month
        }
    }
}

extension ISO_8601.CalendarDate.Month {

    /// The month `YYYY-MM` spells, or `nil` when it spells none.
    public init?(extended text: some StringProtocol) {
        let parts = text.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 2, parts[0].count == 4, parts[1].count == 2,
            parts.allSatisfy(ISO_8601.CalendarDate.isDigits),
            let year = Int(parts[0]), let month = Int(parts[1])
        else { return nil }
        do throws(ISO_8601.CalendarDate.Error) {
            try self.init(year: year, month: month)
        } catch {
            return nil
        }
    }

    /// `YYYY-MM`. ISO 8601 has no basic form of this: `YYYYMM` is too easily read as a two-digit century's date.
    public var extended: String {
        ISO_8601.CalendarDate.digits(year, 4) + "-" + ISO_8601.CalendarDate.digits(month, 2)
    }

    public var numberOfDays: Int {
        ISO_8601.CalendarDate.numberOfDays(inMonth: month, year: year)
    }
}

extension ISO_8601.CalendarDate.Month: Comparable {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.year, lhs.month) < (rhs.year, rhs.month)
    }
}

extension ISO_8601.CalendarDate.Month: CustomStringConvertible {

    public var description: String { extended }
}

extension ISO_8601.CalendarDate.Month: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        guard let month = Self(extended: text) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "not a YYYY-MM month: \(text)")
        }
        self = month
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(extended)
    }
}
