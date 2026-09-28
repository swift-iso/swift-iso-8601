extension ISO_8601.Time {

    public enum Error: Swift.Error, Sendable, Equatable {

        case hourOutOfRange(Int)

        case minuteOutOfRange(Int)

        case secondOutOfRange(Int)

        case nanosecondsOutOfRange(Int)

        case invalidEndOfDay
    }
}
