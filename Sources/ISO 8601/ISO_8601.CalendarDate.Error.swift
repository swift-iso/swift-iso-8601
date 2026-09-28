extension ISO_8601.CalendarDate {

    public enum Error: Swift.Error, Sendable, Equatable {

        case yearOutOfRange(Int)

        case monthOutOfRange(Int)

        case dayOutOfRange(Int, month: Int, year: Int)

        case daysSinceUnixEpochOutOfRange(Int)
    }
}
