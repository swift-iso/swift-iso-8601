//
//  ISO_8601.DateTime.CodingKeys.swift
//  swift-iso-8601
//
//  Codable coding keys for ISO_8601.DateTime
//

extension ISO_8601.DateTime {
    enum CodingKeys: String, CodingKey {
        case secondsSinceEpoch
        case nanoseconds
        case timezoneOffsetSeconds
    }
}
