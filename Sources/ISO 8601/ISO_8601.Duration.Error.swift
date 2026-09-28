extension ISO_8601.Duration {

    public enum Error: Swift.Error, Sendable, Equatable {

        case nanosecondsOutOfRange(Int)
    }
}
