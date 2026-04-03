//
//  ISO_8601.Time.Weekday.swift
//  swift-iso-8601
//
//  ISO 8601 weekday representation
//

// MARK: - Weekday

extension ISO_8601.Time {
    /// Day of the week
    ///
    /// Represents the seven days of the week in both ISO 8601 numbering
    /// (Monday=1) and Gregorian/Western numbering (Sunday=0).
    ///
    /// ## Examples
    /// ```swift
    /// // Calculate weekday from a date
    /// let weekday = Time.Weekday(year: 2024, month: 1, day: 15)
    /// print(weekday)  // monday
    ///
    /// // ISO 8601 numbering (Monday=1, Sunday=7)
    /// let isoNumber = weekday.isoNumber  // 1
    ///
    /// // Gregorian numbering (Sunday=0, Saturday=6)
    /// let gregorianNumber = weekday.gregorianNumber  // 1
    /// ```
    public enum Weekday: Int, Sendable, Equatable, Hashable, CaseIterable, Codable {
        case sunday = 0
        case monday = 1
        case tuesday = 2
        case wednesday = 3
        case thursday = 4
        case friday = 5
        case saturday = 6

        /// Calculate the weekday for a given calendar date
        ///
        /// Uses Zeller's congruence algorithm to determine the day of the week.
        ///
        /// - Parameters:
        ///   - year: The year
        ///   - month: The month (1-12)
        ///   - day: The day of the month (1-31)
        ///   - startingWith: The first day of the week for numbering (default: Sunday for Gregorian)
        /// - Returns: The weekday for the given date
        ///
        /// ## Example
        /// ```swift
        /// let weekday = Time.Weekday(year: 2024, month: 1, day: 15)  // Monday
        /// let isoWeekday = Time.Weekday(year: 2024, month: 1, day: 15, startingWith: .monday)
        /// ```
        public init(year: Int, month: Int, day: Int, startingWith: Weekday = .sunday) {
            let calculatedDay = Self.calculate(year: year, month: month, day: day)
            self = calculatedDay
        }

        /// ISO 8601 weekday number (1=Monday, 2=Tuesday, ..., 7=Sunday)
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

        /// Gregorian/Western weekday number (0=Sunday, 1=Monday, ..., 6=Saturday)
        public var gregorianNumber: Int {
            rawValue
        }

        /// Calculate weekday using Zeller's congruence
        ///
        /// This is an internal helper that uses Zeller's congruence algorithm
        /// to determine the day of the week for any Gregorian calendar date.
        ///
        /// - Parameters:
        ///   - year: The year
        ///   - month: The month (1-12)
        ///   - day: The day of the month
        /// - Returns: The weekday
        internal static func calculate(year: Int, month: Int, day: Int) -> Weekday {
            var y = year
            var m = month

            // Zeller's congruence: treat Jan/Feb as months 13/14 of previous year
            if m < 3 {
                m += 12
                y -= 1
            }

            let q = day
            let k = y % 100  // Year of century
            let j = y / 100  // Zero-based century

            // Zeller's formula
            let h = (q + ((13 * (m + 1)) / 5) + k + (k / 4) + (j / 4) - (2 * j)) % 7

            // Convert from Zeller's (0=Saturday) to Gregorian (0=Sunday)
            let gregorianDay = (h + 6) % 7

            return Weekday(rawValue: gregorianDay)!
        }

        /// Create from ISO 8601 weekday number (1=Monday, ..., 7=Sunday)
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

        /// Create from Gregorian weekday number (0=Sunday, ..., 6=Saturday)
        public init?(gregorianNumber: Int) {
            self.init(rawValue: gregorianNumber)
        }
    }
}
