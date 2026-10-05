public import ASCII
public import Byte
public import Cursor
public import Parser

extension ISO_8601.DateTime {

    public struct Parser<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {

        @inlinable
        public init() {}
    }
}

extension ISO_8601.DateTime.Parser: Parsing {
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf: implement its conformance requirements directly")
        }
    }

    public typealias Failure = __DateTimeParserError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> ISO_8601.DateTime {
        let date = try Self.date(&input)
        let time = try Self.time(&input)
        let offset = try Self.offset(&input)
        guard time.hour < 24 || (time.minute, time.second, time.nanoseconds) == (0, 0, 0) else {
            throw .invalidEndOfDay
        }
        do throws(ISO_8601.DateTime.Error) {
            return try ISO_8601.DateTime(
                date: time.hour == 24 ? Self.following(date) : date,
                hour: time.hour % 24,
                minute: time.minute,
                second: time.second,
                nanoseconds: time.nanoseconds,
                offset: offset
            )
        } catch {
            throw .dateTime(error)
        }
    }
}

extension ISO_8601.DateTime.Parser {

    @usableFromInline
    static func following(
        _ date: ISO_8601.CalendarDate
    ) throws(ISO_8601.DateTime.Error) -> ISO_8601.CalendarDate {
        do throws(ISO_8601.CalendarDate.Error) {
            return try ISO_8601.CalendarDate(daysSinceUnixEpoch: date.daysSinceUnixEpoch + 1)
        } catch {
            throw .date(error)
        }
    }

    @usableFromInline
    static func date(_ input: inout Input) throws(Failure) -> ISO_8601.CalendarDate {
        let mark = input.checkpoint
        var shape = (week: false, dashes: 0, length: 0)
        while let code = input.upcoming(), code != .T, code != .slash {
            _ = input.next()
            shape = (shape.week || code == .W, shape.dashes + (code == .hyphen ? 1 : 0), shape.length + 1)
        }
        input.seek(to: mark)
        return switch shape {
        case (true, _, _): try weekDate(&input)
        case (false, 1, _), (false, 0, 7): try ordinalDate(&input)
        default: try calendarDate(&input)
        }
    }

    @usableFromInline
    static func calendarDate(_ input: inout Input) throws(Failure) -> ISO_8601.CalendarDate {
        let parsed: ISO_8601.CalendarDate.Parse<Input>.Output
        do throws(__ISO8601ParseError) {
            parsed = try ISO_8601.CalendarDate.Parse<Input>().parse(&input)
        } catch {
            throw .dateError(error)
        }
        do throws(ISO_8601.CalendarDate.Error) {
            return try ISO_8601.CalendarDate(year: parsed.year, month: parsed.month, day: parsed.day)
        } catch {
            throw .dateTime(.date(error))
        }
    }

    @usableFromInline
    static func weekDate(_ input: inout Input) throws(Failure) -> ISO_8601.CalendarDate {
        let parsed: ISO_8601.WeekDate.Parse<Input>.Output
        do throws(__ISO8601ParseError) {
            parsed = try ISO_8601.WeekDate.Parse<Input>().parse(&input)
        } catch {
            throw .dateError(error)
        }
        do throws(ISO_8601.WeekDate.Error) {
            return ISO_8601.CalendarDate(
                try ISO_8601.WeekDate(weekYear: parsed.weekYear, week: parsed.week, weekday: parsed.weekday)
            )
        } catch {
            throw .weekDate(error)
        }
    }

    @usableFromInline
    static func ordinalDate(_ input: inout Input) throws(Failure) -> ISO_8601.CalendarDate {
        let parsed: ISO_8601.OrdinalDate.Parse<Input>.Output
        do throws(__ISO8601ParseError) {
            parsed = try ISO_8601.OrdinalDate.Parse<Input>().parse(&input)
        } catch {
            throw .dateError(error)
        }
        do throws(ISO_8601.OrdinalDate.Error) {
            return ISO_8601.CalendarDate(try ISO_8601.OrdinalDate(year: parsed.year, day: parsed.day))
        } catch {
            throw .ordinalDate(error)
        }
    }

    @usableFromInline
    static func time(_ input: inout Input) throws(Failure) -> ISO_8601.Time.Parse<Input>.Output {
        guard input.advance(past: .T) else {
            return ISO_8601.Time.Parse<Input>.Output(hour: 0, minute: 0, second: 0, nanoseconds: 0)
        }
        do throws(__ISO8601ParseError) {
            return try ISO_8601.Time.Parse<Input>().parse(&input)
        } catch {
            throw .timeError(error)
        }
    }

    @usableFromInline
    static func offset(_ input: inout Input) throws(Failure) -> ISO_8601.Timezone.Offset {
        guard let code = input.upcoming(), code == .Z || code == .plus || code == .hyphen else {
            return .utc
        }
        let parsed: ISO_8601.Timezone.Offset.Parse<Input>.Output
        do throws(__ISO8601ParseError) {
            parsed = try ISO_8601.Timezone.Offset.Parse<Input>().parse(&input)
        } catch {
            throw .timezoneError(error)
        }
        do throws(ISO_8601.Timezone.Offset.Error) {
            return try ISO_8601.Timezone.Offset(seconds: parsed.totalSeconds)
        } catch {
            throw .offset(error)
        }
    }
}
