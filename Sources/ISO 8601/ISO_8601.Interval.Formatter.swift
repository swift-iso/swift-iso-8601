extension ISO_8601.Interval {

    public enum Formatter {}
}

extension ISO_8601.Interval.Formatter {

    public static func format(_ value: ISO_8601.Interval) -> String {
        switch value {
        case .startEnd(let start, let end):
            let startStr = start.description
            let endStr = end.description
            return "\(startStr)/\(endStr)"

        case .duration(let duration):
            return duration.description

        case .startDuration(let start, let duration):
            let startStr = start.description
            let durationStr = duration.description
            return "\(startStr)/\(durationStr)"

        case .durationEnd(let duration, let end):
            let durationStr = duration.description
            let endStr = end.description
            return "\(durationStr)/\(endStr)"
        }
    }
}
