extension ISO_8601.RecurringInterval {

    public enum Error: Swift.Error, Sendable, Equatable {

        case negativeRepetitions(Int)
    }
}
