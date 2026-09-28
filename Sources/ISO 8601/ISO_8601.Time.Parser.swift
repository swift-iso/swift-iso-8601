import ASCII
import Byte
import Cursor

extension ISO_8601.Time {

    public enum Parser {}
}

extension ISO_8601.Time.Parser {

    public static func parse(_ value: String) throws(Error) -> ISO_8601.Time {
        var input = [Byte](utf8: value)[...]
        let clock: Clock
        do throws(__ISO8601ParseError) {
            clock = try Self.clock(&input)
        } catch {
            throw .syntax(error)
        }
        let offset = try Self.offset(&input)
        guard input.isEmpty else { throw .unexpectedTrailingInput }
        do throws(ISO_8601.Time.Error) {
            return try ISO_8601.Time(
                hour: clock.hour,
                minute: clock.minute,
                second: clock.second,
                nanoseconds: clock.nanoseconds,
                offset: offset
            )
        } catch {
            throw .time(error)
        }
    }
}

extension ISO_8601.Time.Parser {

    private typealias Clock = (hour: Int, minute: Int?, second: Int?, nanoseconds: Int)

    private static func clock(_ input: inout ArraySlice<Byte>) throws(__ISO8601ParseError) -> Clock {
        let hour = try ISO_8601.Digits<ArraySlice<Byte>>(count: 2).parse(&input)
        let extended = input.advance(past: .colon)
        guard extended || input.upcoming()?.isDigit == true else { return (hour, nil, nil, 0) }
        let minute = try ISO_8601.Digits<ArraySlice<Byte>>(count: 2).parse(&input)
        guard extended ? input.advance(past: .colon) : input.upcoming()?.isDigit == true else {
            return (hour, minute, nil, 0)
        }
        let second = try ISO_8601.Digits<ArraySlice<Byte>>(count: 2).parse(&input)
        return (hour, minute, second, input.nanosecondFraction() ?? 0)
    }

    private static func offset(_ input: inout ArraySlice<Byte>) throws(Error) -> ISO_8601.Timezone.Offset? {
        guard !input.isEmpty else { return nil }
        let parsed: ISO_8601.Timezone.Offset.Parse<ArraySlice<Byte>>.Output
        do throws(__ISO8601ParseError) {
            parsed = try ISO_8601.Timezone.Offset.Parse<ArraySlice<Byte>>().parse(&input)
        } catch {
            throw .syntax(error)
        }
        do throws(ISO_8601.Timezone.Offset.Error) {
            return try ISO_8601.Timezone.Offset(seconds: parsed.totalSeconds)
        } catch {
            throw .offset(error)
        }
    }
}
