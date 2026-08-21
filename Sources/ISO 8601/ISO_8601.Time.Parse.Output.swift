extension ISO_8601.Time.Parse {

    public struct Output: Sendable, Equatable {
        public let hour: Int
        public let minute: Int
        public let second: Int

        public let nanoseconds: Int

        @inlinable
        public init(hour: Int, minute: Int, second: Int, nanoseconds: Int) {
            self.hour = hour
            self.minute = minute
            self.second = second
            self.nanoseconds = nanoseconds
        }
    }
}
