extension ISO_8601.Timezone.Offset {

    public enum Error: Swift.Error, Sendable, Equatable {

        case outOfRange(Int)

        case fractionalMinute(Int)
    }
}
