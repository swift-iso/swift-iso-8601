extension ISO_8601.Interval {

    public enum Formatter {}
}

extension ISO_8601.Interval.Formatter {

    public static func format(_ value: ISO_8601.Interval) -> String {
        switch value {
        case .startEnd(let start, let end):
            let startStr = ISO_8601.DateTime.Formatter.format(start)
            let endStr = ISO_8601.DateTime.Formatter.format(end)
            return "\(startStr)/\(endStr)"

        case .duration(let duration):
            return duration.description

        case .startDuration(let start, let duration):
            let startStr = ISO_8601.DateTime.Formatter.format(start)
            let durationStr = duration.description
            return "\(startStr)/\(durationStr)"

        case .durationEnd(let duration, let end):
            let durationStr = duration.description
            let endStr = ISO_8601.DateTime.Formatter.format(end)
            return "\(durationStr)/\(endStr)"
        }
    }
}
