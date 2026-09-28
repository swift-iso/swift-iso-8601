public import ASCII
public import Byte
public import Cursor
public import Parser

extension ISO_8601 {

    @usableFromInline
    struct Digits<Input: Cursor.`Protocol`>: Sendable
    where Input.Element == Byte, Input.Failure == Never {

        @usableFromInline
        let count: Int

        @inlinable
        init(count: Int) {
            self.count = count
        }
    }
}

extension ISO_8601.Digits: Parsing {

    @usableFromInline
    typealias Output = Int

    @usableFromInline
    typealias Failure = __ISO8601ParseError

    @inlinable
    func parse(_ input: inout Input) throws(Failure) -> Int {
        do throws(ASCII.Decimal.Error) {
            return try ASCII.Decimal.Parser<Input, Int>(count: .exactly(count)).parse(&input)
        } catch {
            throw switch error {
            case .overflow: .overflow
            case .noDigits, .insufficientDigits, .invalidSign, .invalidCount: .expectedDigit
            }
        }
    }
}
