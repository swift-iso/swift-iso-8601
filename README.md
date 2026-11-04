# swift-iso-8601

Use this package when you need to read or write ISO 8601 text: dates and times, durations, intervals and repeating intervals. Start from `ISO_8601.DateTime` for a point in time, `ISO_8601.Duration` for an amount of time, and `ISO_8601.Interval` or `ISO_8601.RecurringInterval` for spans. For the internet timestamp profile only, use swift-rfc-3339.

## Laws

- Years run from 0000 to 9999 and are written with exactly four digits. A date outside that range is refused, including the local date of an instant shown at an offset.
- `ISO_8601.DateTime.init(_:)` reads calendar, week and ordinal dates, in basic or extended form. A date containing W is a week date. A date with one hyphen, or seven characters and no hyphen, is an ordinal date. Anything else is a calendar date.
- A date with no time means midnight. A date-time with no zone designator is taken as UTC.
- The hour 24 is accepted only as 24:00:00 and becomes midnight of the next day.
- `ISO_8601.DateTime` refuses second 60, so a leap second can't be parsed into one. `ISO_8601.Time` keeps second 60.
- A decimal fraction of a second may follow a period or a comma. Digits past the ninth are dropped, not rounded.
- Two `ISO_8601.DateTime` values are equal, hash the same and order by the instant they denote. 12:30+02:00 equals 10:30Z, and each keeps its own offset.
- `ISO_8601.DateTime.Formatter.format(_:date:time:timezone:)` defaults to the extended calendar form in UTC. With the UTC zone it writes the instant converted to UTC with Z. With an offset it writes the local wall clock and the offset. With no zone it writes the local wall clock bare.
- `ISO_8601.DateTime.description` uses Z when the offset is zero and the extended offset otherwise. A fraction is written without trailing zeros, and is left out when zero.
- An offset is at most 23:59 either way and a whole number of minutes. An offset of zero, however written, is the same as Z, and descriptions print it as Z.
- `ISO_8601.Time` keeps the precision it was given, so an hour alone or an hour and minute print back the same way. A missing offset means local time, which is different from Z. Two times are equal only when every field, including the offset, is equal.
- `ISO_8601.Duration` is never normalized. 90 minutes stays 90 minutes and is not equal to 1 hour 30 minutes. A zero duration prints as `PT0S`.
- `ISO_8601.Interval.description` writes its date-times in UTC with Z, so a start or end given with an offset prints converted.
- In an `ISO_8601.RecurringInterval`, R with no count means unlimited repetitions. A count of zero is allowed.
- `ISO_8601.Weekday` numbers Monday as 1 and Sunday as 7 in `ISO_8601.Weekday.isoNumber`, but encodes as its raw value, which counts from Sunday as 0.
- A week year has 53 weeks when January 1 is a Thursday, or a Wednesday in a leap year. Otherwise it has 52. Week 1 is the week that contains January 4.
- `ISO_8601.DateTime`, `ISO_8601.Time`, `ISO_8601.Duration`, `ISO_8601.Interval` and `ISO_8601.RecurringInterval` encode as their description string and decode by parsing it.
