import Foundation

public enum WeatherFormat {
    public static func temperature(_ celsius: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .temperatureWithoutUnit
        formatter.numberFormatter.maximumFractionDigits = 0

        let rounded = celsius.rounded()
        return formatter.string(from: Measurement(value: rounded == 0 ? 0 : rounded, unit: UnitTemperature.celsius))
    }

    public static func percent(_ value: Int) -> String {
        value.formatted(.percent)
    }

    public static func hour(_ date: Date, timeZone: TimeZone) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened)
        style.timeZone = timeZone
        return date.formatted(style)
    }
}
