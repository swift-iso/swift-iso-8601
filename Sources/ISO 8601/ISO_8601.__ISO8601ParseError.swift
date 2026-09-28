public import ASCII

public enum __ISO8601ParseError: Swift.Error, Sendable, Equatable {

    case expectedDigit

    case expected(ASCII.Code)

    case overflow

    case invalidMonth(Int)

    case invalidDay(Int)

    case invalidWeek(Int)

    case invalidWeekday(Int)

    case invalidHour(Int)

    case invalidMinute(Int)

    case invalidSecond(Int)
}
