public enum __ISO8601ParseError: Swift.Error, Sendable, Equatable {

    case expectedDigit

    case unexpectedEndOfInput

    case expectedByte(UInt8)

    case overflow

    case invalidMonth(Int)

    case invalidDay(Int)

    case invalidHour(Int)

    case invalidMinute(Int)

    case invalidSecond(Int)
}
