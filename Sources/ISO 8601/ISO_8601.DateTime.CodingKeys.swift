extension ISO_8601.DateTime {
    enum CodingKeys: String, CodingKey {
        case secondsSinceEpoch
        case nanoseconds
        case timezoneOffsetSeconds
    }
}
