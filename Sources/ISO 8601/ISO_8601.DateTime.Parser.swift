//
//  ISO_8601.DateTime.Parser.swift
//  swift-iso-8601
//
//  ISO 8601 date-time: Date ["T" Time [Timezone]]
//
//  Output is the domain value ISO_8601.DateTime. The date field is discriminated
//  positionally (§E(B)) — presence of 'W', dash-count / digit-run-length before
//  'T' or end — then the one matching sub-grammar leaf runs
//  (CalendarDate.Parse | WeekDate.Parse | OrdinalDate.Parse). The 'T' separator
//  and the time/timezone are optional (date-only inputs like "2024-01-15" are
//  valid). 24:00:00 rolls over to 00:00:00 of the next day per ISO 8601.
//

public import Byte_Primitives
public import Parser_Primitives
public import Time_Primitives

extension ISO_8601.DateTime {
    /// Parses an ISO 8601 date-time into an ``ISO_8601/DateTime``.
    ///
    /// Accepts all three date representations in extended and basic form
    /// (calendar `2024-01-15` / `20240115`, week `2024-W03-1` / `2024W031`,
    /// ordinal `2024-039` / `2024039`), optionally followed by `T` + a time
    /// (seconds optional) and an optional timezone (`Z`, `±HH:MM`, `±HHMM`).
    public struct Parser<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == Byte {
        @inlinable
        public init() {}
    }
}

extension ISO_8601.DateTime.Parser: Parser.`Protocol` {
    public typealias Failure = __DateTimeParserError

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> ISO_8601.DateTime {
        // 1. Discriminate the date format positionally (§E(B)): scan the date
        //    field (up to 'T' 0x54, '/' 0x2F, or end) without consuming.
        var probe = input.startIndex
        var hasWeekDesignator = false
        var dashCount = 0
        var fieldLength = 0
        while probe < input.endIndex {
            let byte = input[probe]
            if byte == 0x54 || byte == 0x2F { break }
            if byte == 0x57 {
                hasWeekDesignator = true
            } else if byte == 0x2D {
                dashCount += 1
            }
            fieldLength += 1
            input.formIndex(after: &probe)
        }
        // ISO-8601 date forms are positionally unambiguous: 'W' ⇒ week;
        // otherwise a single dash (YYYY-DDD) or a dash-free 7-run (YYYYDDD)
        // ⇒ ordinal; everything else ⇒ calendar.
        let isWeek = hasWeekDesignator
        let isOrdinal =
            !hasWeekDesignator && (dashCount == 1 || (dashCount == 0 && fieldLength == 7))

        // 2. Run the one matching leaf and reduce to calendar (year, month, day).
        let year: Int
        let month: Int
        let day: Int
        if isWeek {
            let parsed: ISO_8601.WeekDate.Parse<Input>.Output
            do {
                parsed = try ISO_8601.WeekDate.Parse<Input>().parse(&input)
            } catch {
                throw .dateError(error)
            }
            let weekDate: ISO_8601.WeekDate
            do {
                weekDate = try ISO_8601.WeekDate(
                    weekYear: parsed.weekYear,
                    week: parsed.week,
                    weekday: parsed.weekday
                )
            } catch {
                throw .invalidComponents(error)
            }
            let components = ISO_8601.DateTime(weekDate).components
            (year, month, day) = (components.year, components.month, components.day)
        } else if isOrdinal {
            let parsed: ISO_8601.OrdinalDate.Parse<Input>.Output
            do {
                parsed = try ISO_8601.OrdinalDate.Parse<Input>().parse(&input)
            } catch {
                throw .dateError(error)
            }
            let ordinalDate: ISO_8601.OrdinalDate
            do {
                ordinalDate = try ISO_8601.OrdinalDate(year: parsed.year, day: parsed.day)
            } catch {
                throw .invalidComponents(error)
            }
            let components = ISO_8601.DateTime(ordinalDate).components
            (year, month, day) = (components.year, components.month, components.day)
        } else {
            let parsed: ISO_8601.CalendarDate.Parse<Input>.Output
            do {
                parsed = try ISO_8601.CalendarDate.Parse<Input>().parse(&input)
            } catch {
                throw .dateError(error)
            }
            (year, month, day) = (parsed.year, parsed.month, parsed.day)
        }

        // 3. Optional time, introduced by 'T' (0x54). Seconds are optional.
        var hour = 0
        var minute = 0
        var second = 0
        var nanoseconds = 0
        if input.startIndex < input.endIndex, input[input.startIndex] == 0x54 {
            input = input[input.index(after: input.startIndex)...]
            let time: ISO_8601.Time.Parse<Input>.Output
            do {
                time = try ISO_8601.Time.Parse<Input>().parse(&input)
            } catch {
                throw .timeError(error)
            }
            (hour, minute, second, nanoseconds) =
                (time.hour, time.minute, time.second, time.nanoseconds)
        }

        // 4. Optional timezone: 'Z' (0x5A), '+' (0x2B), '-' (0x2D).
        var timezoneOffset = 0
        if input.startIndex < input.endIndex {
            let byte = input[input.startIndex]
            if byte == 0x5A || byte == 0x2B || byte == 0x2D {
                let offset: ISO_8601.Timezone.Offset.Parse<Input>.Output
                do {
                    offset = try ISO_8601.Timezone.Offset.Parse<Input>().parse(&input)
                } catch {
                    throw .timezoneError(error)
                }
                timezoneOffset = offset.totalSeconds
            }
        }

        // 5. 24:00:00 ⇒ 00:00:00 of the next day (ISO 8601).
        if hour == 24 {
            guard minute == 0, second == 0, nanoseconds == 0 else {
                throw .invalidComponents(
                    .invalidTime("24:xx:xx is not valid, only 24:00:00 is allowed")
                )
            }
            let startOfDay: ISO_8601.DateTime
            do {
                startOfDay = try ISO_8601.DateTime(
                    year: year,
                    month: month,
                    day: day,
                    hour: 0,
                    minute: 0,
                    second: 0,
                    nanoseconds: 0,
                    timezoneOffsetSeconds: timezoneOffset
                )
            } catch {
                throw .invalidComponents(error)
            }
            do {
                return try ISO_8601.DateTime(
                    secondsSinceEpoch: startOfDay.epoch.seconds
                        + Time_Primitives.Time.Calendar.Gregorian.TimeConstants.secondsPerDay,
                    nanoseconds: 0,
                    timezoneOffsetSeconds: timezoneOffset
                )
            } catch {
                throw .invalidComponents(error)
            }
        }

        // 6. Construct the domain value, mapping component-validation failures.
        do {
            return try ISO_8601.DateTime(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                nanoseconds: nanoseconds,
                timezoneOffsetSeconds: timezoneOffset
            )
        } catch {
            throw .invalidComponents(error)
        }
    }
}
