//
//  ISO_8601.DateTime.Epoch.swift
//  swift-iso-8601
//
//  Epoch accessor for ISO 8601 DateTime
//

import Time_Primitives

extension ISO_8601.DateTime {
    /// Accessor for epoch-relative properties
    public struct Epoch: Sendable {
        internal let dateTime: ISO_8601.DateTime

        /// Seconds since Unix epoch (UTC)
        public var seconds: Int {
            dateTime.time.secondsSinceEpoch
        }
    }
}
