//
//  ISO_8601.Timezone.Offset.Parse.Output.swift
//  swift-iso-8601
//
//  ISO 8601 timezone offset parse output
//

extension ISO_8601.Timezone.Offset.Parse {
    public struct Output: Sendable, Equatable {
        /// Offset from UTC in seconds. Zero for `Z`.
        public let totalSeconds: Int

        @inlinable
        public init(totalSeconds: Int) {
            self.totalSeconds = totalSeconds
        }
    }
}
