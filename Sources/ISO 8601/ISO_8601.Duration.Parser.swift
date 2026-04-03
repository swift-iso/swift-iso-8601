//
//  ISO_8601.Duration.Parser.swift
//  swift-iso-8601
//
//  ISO 8601 duration parser
//

// MARK: - Parsing

extension ISO_8601.Duration {
    /// Parser for ISO 8601 duration strings
    public enum Parser {
        /// Parse an ISO 8601 duration string
        ///
        /// - Parameter value: The P-format duration string (e.g., "P1Y2M3DT4H5M6.789S")
        /// - Returns: Duration instance
        /// - Throws: `ISO_8601.Date.Error` if parsing fails
        public static func parse(_ value: String) throws(ISO_8601.Date.Error) -> ISO_8601.Duration {
            guard value.hasPrefix("P") else {
                throw ISO_8601.Date.Error.invalidFormat("Duration must start with 'P'")
            }

            let remaining = String(value.dropFirst())

            guard !remaining.isEmpty else {
                throw ISO_8601.Date.Error.invalidFormat("Duration cannot be just 'P'")
            }

            // Validate that remaining contains at least one valid component marker
            let validMarkers: Set<Character> = ["Y", "M", "D", "T", "H", "S"]
            guard remaining.contains(where: { validMarkers.contains($0) }) else {
                throw ISO_8601.Date.Error.invalidFormat(
                    "Duration must have at least one valid component"
                )
            }

            var years = 0
            var months = 0
            var days = 0
            var hours = 0
            var minutes = 0
            var seconds = 0
            var nanoseconds = 0

            // Check for T separator
            if let tIndex = remaining.firstIndex(of: "T") {
                // Has both date and time parts
                let datePart = String(remaining[..<tIndex])
                let timePart = String(remaining[remaining.index(after: tIndex)...])

                // Parse date part if not empty
                if !datePart.isEmpty {
                    (years, months, days) = try parseDateComponents(datePart)
                }

                // Parse time part if not empty
                if !timePart.isEmpty {
                    (hours, minutes, seconds, nanoseconds) = try parseTimeComponents(timePart)
                }
            } else {
                // No T, only date components
                (years, months, days) = try parseDateComponents(remaining)
            }

            return try ISO_8601.Duration(
                years: years,
                months: months,
                days: days,
                hours: hours,
                minutes: minutes,
                seconds: seconds,
                nanoseconds: nanoseconds
            )
        }

        private static func parseDateComponents(
            _ datePart: String
        ) throws(ISO_8601.Date.Error) -> (years: Int, months: Int, days: Int) {
            var years = 0
            var months = 0
            var days = 0
            var scanner = datePart[...]

            // Years
            if let yIndex = scanner.firstIndex(of: "Y") {
                let numStr = String(scanner[..<yIndex])
                guard !numStr.isEmpty, let num = Int(numStr) else {
                    throw ISO_8601.Date.Error.invalidFormat("Invalid year component")
                }
                years = num
                scanner = scanner[scanner.index(after: yIndex)...]
            }

            // Months
            if let mIndex = scanner.firstIndex(of: "M") {
                let numStr = String(scanner[..<mIndex])
                guard !numStr.isEmpty, let num = Int(numStr) else {
                    throw ISO_8601.Date.Error.invalidFormat("Invalid month component")
                }
                months = num
                scanner = scanner[scanner.index(after: mIndex)...]
            }

            // Days
            if let dIndex = scanner.firstIndex(of: "D") {
                let numStr = String(scanner[..<dIndex])
                guard !numStr.isEmpty, let num = Int(numStr) else {
                    throw ISO_8601.Date.Error.invalidFormat("Invalid day component")
                }
                days = num
            }

            return (years, months, days)
        }

        private static func parseTimeComponents(
            _ timePart: String
        ) throws(ISO_8601.Date.Error) -> (hours: Int, minutes: Int, seconds: Int, nanoseconds: Int) {
            var hours = 0
            var minutes = 0
            var seconds = 0
            var nanoseconds = 0
            var scanner = timePart[...]

            // Hours
            if let hIndex = scanner.firstIndex(of: "H") {
                let numStr = String(scanner[..<hIndex])
                guard !numStr.isEmpty, let num = Int(numStr) else {
                    throw ISO_8601.Date.Error.invalidFormat("Invalid hour component")
                }
                hours = num
                scanner = scanner[scanner.index(after: hIndex)...]
            }

            // Minutes
            if let mIndex = scanner.firstIndex(of: "M") {
                let numStr = String(scanner[..<mIndex])
                guard !numStr.isEmpty, let num = Int(numStr) else {
                    throw ISO_8601.Date.Error.invalidFormat("Invalid minute component")
                }
                minutes = num
                scanner = scanner[scanner.index(after: mIndex)...]
            }

            // Seconds (may include fractional)
            if let sIndex = scanner.firstIndex(of: "S") {
                let numStr = String(scanner[..<sIndex])

                guard !numStr.isEmpty else {
                    throw ISO_8601.Date.Error.invalidFormat("Invalid second component")
                }

                // Check for decimal point or comma
                if numStr.contains(".") || numStr.contains(",") {
                    let separator = numStr.contains(".") ? "." : ","
                    let comps = numStr.split(separator: Character(separator)).map(String.init)
                    guard comps.count == 2 else {
                        throw ISO_8601.Date.Error.invalidFormat("Invalid fractional seconds")
                    }

                    guard let sec = Int(comps[0]) else {
                        throw ISO_8601.Date.Error.invalidSecond(comps[0])
                    }
                    seconds = sec

                    // Parse fractional part
                    let fracStr = comps[1]
                    // Pad or truncate to 9 digits (nanoseconds)
                    var paddedFrac = fracStr
                    if fracStr.count < 9 {
                        paddedFrac = fracStr + String(repeating: "0", count: 9 - fracStr.count)
                    } else if fracStr.count > 9 {
                        paddedFrac = String(fracStr.prefix(9))
                    }
                    guard let nano = Int(paddedFrac) else {
                        throw ISO_8601.Date.Error.invalidFractionalSecond(fracStr)
                    }
                    nanoseconds = nano
                } else {
                    guard let sec = Int(numStr) else {
                        throw ISO_8601.Date.Error.invalidSecond(numStr)
                    }
                    seconds = sec
                }
            }

            return (hours, minutes, seconds, nanoseconds)
        }
    }
}
