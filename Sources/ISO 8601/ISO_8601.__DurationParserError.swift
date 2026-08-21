public enum __DurationParserError: Swift.Error, Sendable, Equatable {

    case expectedP

    case emptyDuration

    case expectedComponentDesignator

    case invalidDigit

    case overflow

    case unexpectedTrailingInput
}
