//
//  ISO_8601.DateTime.Parse.Output.swift
//  swift-iso-8601
//

extension ISO_8601.DateTime.Parse {
    public struct Output: Sendable, Equatable {
        public let date: ISO_8601.Parse.CalendarDate<Input>.Output
        public let time: ISO_8601.Time.Parse<Input>.Output
        public let timezone: ISO_8601.Timezone.Offset.Parse<Input>.Output?

        @inlinable
        public init(
            date: ISO_8601.Parse.CalendarDate<Input>.Output,
            time: ISO_8601.Time.Parse<Input>.Output,
            timezone: ISO_8601.Timezone.Offset.Parse<Input>.Output?
        ) {
            self.date = date
            self.time = time
            self.timezone = timezone
        }
    }
}
