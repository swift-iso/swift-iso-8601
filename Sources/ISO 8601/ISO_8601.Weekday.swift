extension ISO_8601 {

    public enum Weekday: Int, Sendable, Hashable, CaseIterable, Codable {
        case sunday = 0
        case monday = 1
        case tuesday = 2
        case wednesday = 3
        case thursday = 4
        case friday = 5
        case saturday = 6
    }
}

extension ISO_8601.Weekday {

    public init?(isoNumber: Int) {
        guard (1...7).contains(isoNumber) else { return nil }
        self = Self.allCases[isoNumber % 7]
    }

    public init?(gregorianNumber: Int) {
        self.init(rawValue: gregorianNumber)
    }

    init(daysSinceUnixEpoch days: Int) {
        self = Self.allCases[((days % 7) + 7 + 4) % 7]
    }

    public var isoNumber: Int {
        (rawValue + 6) % 7 + 1
    }

    public var gregorianNumber: Int {
        rawValue
    }
}
