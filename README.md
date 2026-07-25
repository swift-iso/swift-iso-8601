# swift-iso-8601

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Swift implementation of the ISO 8601:2019 date and time format.

## Standard Reference

- **ISO**: 8601:2019
- **Title**: Date and time — Representations for information interchange

## Supported Formats

ISO 8601 supports three date representations.

### Calendar Date

```swift
// Extended format
"2024-01-15T12:30:00Z"

// Basic format
"20240115T123000Z"
```

### Week Date

```swift
// Extended format
"2024-W03-2T12:30:00Z"  // Year 2024, Week 3, Tuesday

// Basic format
"2024W032T123000Z"
```

### Ordinal Date

```swift
// Extended format
"2024-039T12:30:00Z"  // Year 2024, day 39

// Basic format
"2024039T123000Z"
```

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-iso/swift-iso-8601.git", from: "0.2.3")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "ISO 8601", package: "swift-iso-8601")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).

## References

- [ISO 8601:2019](https://www.iso.org/iso-8601-date-and-time-format.html) — Official standard.
- [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339.html) — ISO 8601 profile for Internet protocols.
