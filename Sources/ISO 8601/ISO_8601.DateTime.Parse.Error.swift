//
//  ISO_8601.DateTime.Parse.Error.swift
//  swift-iso-8601
//

extension ISO_8601.DateTime.Parse {
    public enum Error: Swift.Error, Sendable, Equatable {
        case expectedT
        case dateError(ISO_8601.Parse.Error)
        case timeError(ISO_8601.Parse.Error)
        case timezoneError(ISO_8601.Parse.Error)
    }
}
