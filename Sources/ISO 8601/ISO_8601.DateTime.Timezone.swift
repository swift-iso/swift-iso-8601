//
//  ISO_8601.DateTime.Timezone.swift
//  swift-iso-8601
//
//  Timezone accessor for ISO 8601 DateTime
//

import Time_Primitives

extension ISO_8601.DateTime {
    /// Accessor for timezone-related properties
    public struct Timezone: Sendable {
        internal let dateTime: ISO_8601.DateTime

        /// Timezone offset from UTC in seconds
        ///
        /// Positive values are east of UTC, negative values are west.
        public var offsetSeconds: Int {
            dateTime.timezoneOffset.seconds
        }
    }
}
