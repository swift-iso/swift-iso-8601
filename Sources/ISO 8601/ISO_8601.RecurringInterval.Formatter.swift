extension ISO_8601.RecurringInterval {

    public enum Formatter {}
}

extension ISO_8601.RecurringInterval.Formatter {

    public static func format(_ value: ISO_8601.RecurringInterval) -> String {
        let prefix: String
        if let reps = value.repetitions {
            prefix = "R\(reps)"
        } else {
            prefix = "R"
        }

        let intervalStr = ISO_8601.Interval.Formatter.format(value.interval)
        return "\(prefix)/\(intervalStr)"
    }
}
