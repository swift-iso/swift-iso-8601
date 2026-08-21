extension ISO_8601.Duration {

    public enum Formatter {}
}

extension ISO_8601.Duration.Formatter {

    public static func format(_ value: ISO_8601.Duration) -> String {

        if value.isZero {
            return "PT0S"
        }

        var result = "P"

        if value.years != 0 {
            result += "\(value.years)Y"
        }
        if value.months != 0 {
            result += "\(value.months)M"
        }
        if value.days != 0 {
            result += "\(value.days)D"
        }

        let hasTimeComponents =
            value.hours != 0 || value.minutes != 0 || value.seconds != 0
            || value.nanoseconds != 0

        if hasTimeComponents {
            result += "T"

            if value.hours != 0 {
                result += "\(value.hours)H"
            }
            if value.minutes != 0 {
                result += "\(value.minutes)M"
            }
            if value.seconds != 0 || value.nanoseconds != 0 {
                if value.nanoseconds == 0 {
                    result += "\(value.seconds)S"
                } else {

                    let fractional = formatFractionalSeconds(
                        seconds: value.seconds,
                        nanoseconds: value.nanoseconds
                    )
                    result += "\(fractional)S"
                }
            }
        }

        return result
    }

    private static func formatFractionalSeconds(seconds: Int, nanoseconds: Int) -> String {

        var nano = nanoseconds
        var divisor = 1
        while nano > 0 && nano % 10 == 0 {
            nano /= 10
            divisor *= 10
        }

        if nano == 0 {
            return "\(seconds)"
        }

        return "\(seconds).\(nano)"
    }
}
