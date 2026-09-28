extension ISO_8601.Time {

    public enum Formatter {}
}

extension ISO_8601.Time.Formatter {

    public static func format(_ value: ISO_8601.Time, format: Format = .extended) -> String {
        let extended = format == .extended
        let clock = [value.hour, value.minute, value.second]
            .prefix { $0 != nil }
            .compactMap { $0 }
            .map { ISO_8601.Numeral.padded($0, width: 2) }
            .joined(separator: extended ? ":" : "")
        let fraction = value.second == nil ? "" : ISO_8601.Numeral.fraction(nanoseconds: value.nanoseconds)
        let offset =
            switch value.offset {
            case nil: ""
            case .utc?: "Z"
            case let offset?: offset.formatted(extended: extended)
            }
        return clock + fraction + offset
    }
}
