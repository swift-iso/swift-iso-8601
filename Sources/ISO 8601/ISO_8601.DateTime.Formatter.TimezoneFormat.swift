extension ISO_8601.DateTime.Formatter {

    public enum TimezoneFormat {
        case none
        case utc
        case offset(extended: Bool)
    }
}
