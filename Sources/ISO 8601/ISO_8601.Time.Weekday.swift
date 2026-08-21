extension ISO_8601.Time {

    public enum Weekday: Int, Sendable, Equatable, Hashable, CaseIterable, Codable {
        case sunday = 0
        case monday = 1
        case tuesday = 2
        case wednesday = 3
        case thursday = 4
        case friday = 5
        case saturday = 6

        public init(year: Int, month: Int, day: Int, startingWith: Weekday = .sunday) {
            let calculatedDay = Self.calculate(year: year, month: month, day: day)
            self = calculatedDay
        }

        public init?(isoNumber: Int) {
            switch isoNumber {
            case 1: self = .monday
            case 2: self = .tuesday
            case 3: self = .wednesday
            case 4: self = .thursday
            case 5: self = .friday
            case 6: self = .saturday
            case 7: self = .sunday
            default: return nil
            }
        }

        public init?(gregorianNumber: Int) {
            self.init(rawValue: gregorianNumber)
        }
    }
}

extension ISO_8601.Time.Weekday {

    public var isoNumber: Int {
        switch self {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        }
    }

    public var gregorianNumber: Int {
        rawValue
    }

    internal static func calculate(year: Int, month: Int, day: Int) -> Self {
        var y = year
        var m = month

        if m < 3 {
            m += 12
            y -= 1
        }

        let q = day
        let k = y % 100
        let j = y / 100

        let h = (q + ((13 * (m + 1)) / 5) + k + (k / 4) + (j / 4) - (2 * j)) % 7

        let gregorianDay = (h + 6) % 7

        return Self(rawValue: gregorianDay)!
    }
}
