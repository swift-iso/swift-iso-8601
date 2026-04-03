//
//  ISO_8601.Time.Timezone.swift
//  swift-iso-8601
//
//  Timezone accessor for ISO 8601 Time
//

extension ISO_8601.Time {
    /// Accessor for timezone-related properties
    public struct Timezone: Sendable {
        internal let time: ISO_8601.Time

        /// Timezone offset from UTC in seconds, nil if not specified
        ///
        /// Positive values are east of UTC, negative values are west.
        public var offsetSeconds: Int? {
            time._timezoneOffsetSeconds
        }
    }
}
