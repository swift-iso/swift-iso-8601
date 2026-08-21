extension ISO_8601.Time {

    public struct Timezone: Sendable {
        internal let time: ISO_8601.Time
    }
}

extension ISO_8601.Time.Timezone {

    public var offsetSeconds: Int? {
        time._timezoneOffsetSeconds
    }
}
