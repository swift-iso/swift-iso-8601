extension ISO_8601.Timezone.Offset.Parse {

    public struct Output: Sendable, Equatable {

        public let totalSeconds: Int

        @inlinable
        public init(totalSeconds: Int) {
            self.totalSeconds = totalSeconds
        }
    }
}
