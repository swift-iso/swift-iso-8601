extension ISO_8601.OrdinalDate {

    public enum Error: Swift.Error, Sendable, Equatable {

        case yearOutOfRange(Int)

        case dayOutOfRange(Int, year: Int)
    }
}
