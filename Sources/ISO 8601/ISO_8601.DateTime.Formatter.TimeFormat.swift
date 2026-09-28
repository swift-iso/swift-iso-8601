extension ISO_8601.DateTime.Formatter {

    public enum TimeFormat: Sendable, Equatable {
        case none
        case time(extended: Bool)
    }
}
