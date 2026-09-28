extension ISO_8601.WeekDate {

    public enum Error: Swift.Error, Sendable, Equatable {

        case yearOutOfRange(Int)

        case weekOutOfRange(Int, weekYear: Int)

        case weekdayOutOfRange(Int)
    }
}
