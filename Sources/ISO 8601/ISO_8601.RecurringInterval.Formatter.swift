extension ISO_8601.RecurringInterval {

    public enum Formatter {}
}

extension ISO_8601.RecurringInterval.Formatter {

    public static func format(_ value: ISO_8601.RecurringInterval) -> String {
        let prefix: String
        prefix =
            if let reps = value.repetitions {
                "R\(reps)"
            } else {
                "R"
            }

        let intervalStr = ISO_8601.Interval.Formatter.format(value.interval)
        return "\(prefix)/\(intervalStr)"
    }
}
