//
//  ISO_8601.DateTime.Parse.Error.swift
//  swift-iso-8601
//

extension ISO_8601.DateTime.Parse {
    /// Errors that can occur when parsing an ISO 8601 date-time.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The input did not contain the required `T` separator between date and time.
        case expectedT
        /// The date portion of the date-time was invalid.
        case dateError(ISO_8601.Parse.Error)
        /// The time portion of the date-time was invalid.
        case timeError(ISO_8601.Parse.Error)
        /// The timezone offset portion was invalid.
        case timezoneError(ISO_8601.Parse.Error)
    }
}
