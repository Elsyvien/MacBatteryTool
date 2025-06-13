
import Foundation
import IOKit    // <-- Wichtig fürs Kompilieren:  -framework IOKit

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

        // 3. µW → W: |U · I| / 1 000 000
        return abs(Double(voltage) * Double(amperage)) / 1_000_000
    }

    /// Bewertungssymbol anhand Watt
    func rating(for watt: Double) -> String {
        switch watt {
        case ..<2.0:  return "🟢"
        case 2.0..<5: return "🟡"
        default:      return "🔴"
        }
    }
}
