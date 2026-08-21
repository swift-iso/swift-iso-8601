public enum __DateTimeParserError: Swift.Error, Sendable, Equatable {

    case expectedT

    case dateError(__ISO8601ParseError)

    case timeError(__ISO8601ParseError)

    case timezoneError(__ISO8601ParseError)

    case invalidComponents(ISO_8601.Date.Error)

    case unexpectedTrailingInput
}
