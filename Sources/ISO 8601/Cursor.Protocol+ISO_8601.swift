public import ASCII
public import Byte
public import Cursor

extension Cursor.`Protocol` where Element == Byte, Failure == Never {

    @usableFromInline
    mutating func upcoming() -> ASCII.Code? {
        let mark = checkpoint
        defer { seek(to: mark) }
        return next().flatMap { byte in try? ASCII.Code(byte) }
    }

    @usableFromInline
    mutating func advance(past code: ASCII.Code) -> Bool {
        guard upcoming() == code else { return false }
        _ = next()
        return true
    }

    @usableFromInline
    mutating func decimalDigit() -> Int? {
        guard let code = upcoming(), code.isDigit else { return nil }
        _ = next()
        return Int(code.underlying &- ASCII.Code.`0`.underlying)
    }

    @usableFromInline
    mutating func nanosecondFraction() -> Int? {
        guard advance(past: .period) || advance(past: .comma) else { return nil }
        var digits: [Int] = []
        while let digit = decimalDigit() { digits.append(digit) }
        return (digits.prefix(9) + repeatElement(0, count: max(0, 9 - digits.count)))
            .reduce(0) { $0 * 10 + $1 }
    }
}
