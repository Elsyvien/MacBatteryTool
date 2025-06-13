import Foundation
import IOKit 

final class BatteryReader {

    static let shared = BatteryReader()

    /// Liefert Leistung in Watt oder nil, falls nicht verfügbar.
    func readWatt() -> Double? {

        // 1. AppleSmartBattery-Service holen
        let service = IOServiceGetMatchingService(kIOMainPortDefault,
                                                  IOServiceNameMatching("AppleSmartBattery"))
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }

        // 2. Properties aus dem Registry-Eintrag lesen
        guard
            let voltageAny =
                IORegistryEntryCreateCFProperty(service,
                                                "Voltage" as CFString,
                                                kCFAllocatorDefault, 0)?
                .takeRetainedValue(),
            let amperageAny =
                IORegistryEntryCreateCFProperty(service,
                                                "InstantAmperage" as CFString,
                                                kCFAllocatorDefault, 0)?
                .takeRetainedValue(),
            let voltage = voltageAny as? Int,
            let amperage = amperageAny as? Int
        else { return nil }

        let result = abs(Double(voltage) * Double(amperage)) / 1_000_000
        print(result)
        // 3. µW → W: |U · I| / 1 000 000
        return result
    }
    // Prozent Lesen
    func readPercentage() -> Int? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault,
                                                  IOServiceNameMatching("AppleSmartBattery"))
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }

        guard
            let percentAny = IORegistryEntryCreateCFProperty(service, "CurrentCapacity" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue(),
            let maxAny = IORegistryEntryCreateCFProperty(service, "MaxCapacity" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue(),
            let current = percentAny as? Int,
            let max = maxAny as? Int,
            max > 0
        else {
            return nil
        }

        return Int((Float(current) / Float(max)) * 100)
    }
    /// Bewertungssymbol anhand Watt
    func rating(for watt: Double) -> String {
        switch watt {
        case ..<5.0:
            return "🟢"
        case 5.0..<15.0:
            return "🟡"
        default:
            return "🔴"
        }
    }
}
