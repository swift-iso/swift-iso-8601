import Testing

@testable import ISO_8601

@Suite
struct `DateTime ranges` {
    @Test(arguments: [
        "2024-13-01", "2024-00-10", "2024-02-30", "2023-02-29", "2024-04-31", "2024-01-32",
        "2024-01-15T25:00:00Z", "2024-01-15T12:60:00Z", "2024-01-15T12:00:61Z",
        "2024-01-15T12:00:00+25:00", "2024-01-15T12:00:00+01:60", "2024-W54-1", "2024-W01-8",
        "2024-367", "2023-366", "2024-01-15T12:00:00+0100x",
    ])
    func `an out-of-range or malformed value is refused`(_ text: String) {
        #expect(throws: (any Error).self) {
            try ISO_8601.DateTime(text)
        }
    }

    @Test(arguments: ["2024-02-29", "2024-366", "2024-01-15T24:00:00Z", "2024-01-15T12:00:00-12:00", "2020-W53-7"])
    func `boundary values that ISO 8601 allows parse`(_ text: String) throws {
        _ = try ISO_8601.DateTime(text)
    }
}
