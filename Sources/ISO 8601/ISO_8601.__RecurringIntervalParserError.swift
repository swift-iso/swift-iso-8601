public enum __RecurringIntervalParserError: Swift.Error, Sendable, Equatable {

    case expectedR

    case expectedSlash

    case intervalError(__IntervalParserError)

    case overflow

    case recurringInterval(ISO_8601.RecurringInterval.Error)

    case unexpectedTrailingInput
}
