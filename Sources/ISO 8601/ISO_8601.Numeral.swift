extension ISO_8601 {

    enum Numeral {}
}

extension ISO_8601.Numeral {

    static func padded(_ value: Int, width: Int) -> String {
        let digits = String(value.magnitude)
        return (value < 0 ? "-" : "")
            + String(repeating: "0", count: max(0, width - digits.count))
            + digits
    }

    static func fraction(nanoseconds: Int) -> String {
        nanoseconds == 0
            ? ""
            : "." + String(padded(nanoseconds, width: 9).reversed().drop { $0 == "0" }.reversed())
    }
}
