public enum __DateTimeParserError: Swift.Error, Sendable, Equatable {

    case expectedT

    case dateError(__ISO8601ParseError)

    case timeError(__ISO8601ParseError)

    case timezoneError(__ISO8601ParseError)

    case weekDate(ISO_8601.WeekDate.Error)

    case ordinalDate(ISO_8601.OrdinalDate.Error)

    case offset(ISO_8601.Timezone.Offset.Error)

    case dateTime(ISO_8601.DateTime.Error)

    case invalidEndOfDay

    case unexpectedTrailingInput
}
