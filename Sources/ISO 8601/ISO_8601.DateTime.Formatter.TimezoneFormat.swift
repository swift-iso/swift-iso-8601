extension ISO_8601.DateTime.Formatter {

    public enum TimezoneFormat: Sendable, Equatable {
        case none
        case utc
        case offset(extended: Bool)
    }
}
