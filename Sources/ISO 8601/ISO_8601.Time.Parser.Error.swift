extension ISO_8601.Time.Parser {

    public enum Error: Swift.Error, Sendable, Equatable {

        case syntax(__ISO8601ParseError)

        case time(ISO_8601.Time.Error)

        case offset(ISO_8601.Timezone.Offset.Error)

        case unexpectedTrailingInput
    }
}
