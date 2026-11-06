extension ISO_8601.CalendarDate {

    /// The date `YYYY-MM-DD` spells, or `nil` when it spells none.
    public init?(extended text: some StringProtocol) {
        let parts = text.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3, parts[0].count == 4, parts[1].count == 2, parts[2].count == 2,
            parts.allSatisfy(Self.isDigits),
            let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2])
        else { return nil }
        do throws(Error) {
            try self.init(year: year, month: month, day: day)
        } catch {
            return nil
        }
    }

    /// `YYYY-MM-DD`.
    public var extended: String {
        Self.digits(year, 4) + "-" + Self.digits(month, 2) + "-" + Self.digits(day, 2)
    }

    /// `YYYYMMDD`.
    public var basic: String {
        Self.digits(year, 4) + Self.digits(month, 2) + Self.digits(day, 2)
    }

    /// Whether `text` is ASCII digits alone: `Int` also reads a leading sign, which no date writes.
    static func isDigits(_ text: some StringProtocol) -> Bool {
        text.utf8.allSatisfy { (0x30...0x39).contains($0) }
    }

    static func digits(_ value: Int, _ count: Int) -> String {
        let text = String(value)
        return String(repeating: "0", count: max(0, count - text.count)) + text
    }
}

extension ISO_8601.CalendarDate: CustomStringConvertible {

    public var description: String { extended }
}

extension ISO_8601.CalendarDate: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        guard let date = Self(extended: text) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "not a YYYY-MM-DD date: \(text)")
        }
        self = date
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(extended)
    }
}
