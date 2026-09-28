extension ISO_8601.DateTime.Formatter {

    public enum DateFormat: Sendable, Equatable {
        case calendar(extended: Bool)
        case week(extended: Bool)
        case ordinal(extended: Bool)
    }
}
