public enum __DurationParserError: Swift.Error, Sendable, Equatable {

    case expectedP

    case emptyDuration

    case expectedComponentDesignator

    case invalidDigit

    case overflow

    case duration(ISO_8601.Duration.Error)

    case unexpectedTrailingInput
}
