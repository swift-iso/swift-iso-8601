public enum __IntervalParserError: Swift.Error, Sendable, Equatable {

    case dateTimeError(__DateTimeParserError)

    case durationError(__DurationParserError)

    case expectedSlash

    case twoDateTimes

    case twoDurations

    case unexpectedTrailingInput
}
