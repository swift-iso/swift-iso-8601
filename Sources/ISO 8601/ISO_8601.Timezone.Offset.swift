extension ISO_8601.Timezone {

    public struct Offset: Sendable, Hashable, Comparable {

        public let seconds: Int

        public init(seconds: Int) throws(Error) {
            guard seconds.magnitude <= 23 * 3_600 + 59 * 60 else { throw .outOfRange(seconds) }
            guard seconds.isMultiple(of: 60) else { throw .fractionalMinute(seconds) }
            self.init(unchecked: seconds)
        }

        init(unchecked seconds: Int) {
            self.seconds = seconds
        }
    }
}

extension ISO_8601.Timezone.Offset {

    public static let utc = Self(unchecked: 0)

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.seconds < rhs.seconds
    }

    func formatted(extended: Bool) -> String {
        [
            seconds < 0 ? "-" : "+",
            ISO_8601.Numeral.padded(Int(seconds.magnitude) / 3_600, width: 2),
            extended ? ":" : "",
            ISO_8601.Numeral.padded(Int(seconds.magnitude) % 3_600 / 60, width: 2),
        ].joined()
    }
}
