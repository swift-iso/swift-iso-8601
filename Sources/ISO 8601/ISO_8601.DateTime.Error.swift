extension ISO_8601.DateTime {

    public enum Error: Swift.Error, Sendable, Equatable {

        case date(ISO_8601.CalendarDate.Error)

        case hourOutOfRange(Int)

        case minuteOutOfRange(Int)

        case secondOutOfRange(Int)

        case nanosecondsOutOfRange(Int)
    }
}
