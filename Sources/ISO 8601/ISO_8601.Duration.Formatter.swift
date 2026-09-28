extension ISO_8601.Duration {

    public enum Formatter {}
}

extension ISO_8601.Duration.Formatter {

    public static func format(_ value: ISO_8601.Duration) -> String {
        guard !value.isZero else { return "PT0S" }
        let date = [(value.years, "Y"), (value.months, "M"), (value.days, "D")]
            .filter { $0.0 != 0 }
            .map { "\($0.0)\($0.1)" }
            .joined()
        let seconds =
            value.seconds != 0 || value.nanoseconds != 0
            ? "\(value.seconds)" + ISO_8601.Numeral.fraction(nanoseconds: value.nanoseconds) + "S"
            : ""
        let time =
            [(value.hours, "H"), (value.minutes, "M")]
            .filter { $0.0 != 0 }
            .map { "\($0.0)\($0.1)" }
            .joined() + seconds
        return "P" + date + (time.isEmpty ? "" : "T" + time)
    }
}
