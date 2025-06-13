import Foundation

struct BatterySample {
    let time: Date
    let charge: Int
    let max: Int
}

/// Messwert für die aktuelle Leistungsaufnahme in Watt
struct PowerSample {
    let time: Date
    let watt: Double
}

final class BatteryHistory {
    static let shared = BatteryHistory()

    private var samples: [BatterySample] = []
    private var powerSamples: [PowerSample] = []
    private var drainHistory: [Double] = []
    private var runtimeSamples: [Double] = []
    private let maxSamples = 30  // ca. 15–30 Sekunden bei 1–2 s Intervall
    private let maxPowerSamples = 60
    private let maxRuntimeSamples = 60

    private var lastChargeTime = Date()
    private var wasCharging = false

    // Neuen Messwert hinzufügen
    func addSample(charge: (current: Int, max: Int)) {
        let sample = BatterySample(time: Date(), charge: charge.current, max: charge.max)
        samples.append(sample)
        if samples.count > maxSamples { samples.removeFirst() }
    }

    // Leistungsmesswert hinzufügen und Prozentverbrauch errechnen
    func addPowerSample(_ watt: Double, capacityWh: Double = 52.0) {
        let sample = PowerSample(time: Date(), watt: watt)
        powerSamples.append(sample)
        if powerSamples.count > maxPowerSamples { powerSamples.removeFirst() }

        if let drain = averageDrainPerHour(capacityWh: capacityWh) {
            drainHistory.append(drain)
            if drainHistory.count > maxPowerSamples { drainHistory.removeFirst() }
        }
    }

    // Verlaufsliste der gemessenen Leistungswerte
    func powerHistory() -> [Double] {
        return powerSamples.map { $0.watt }
    }

    // Verlaufsliste des errechneten Prozentverbrauchs pro Stunde
    func drainHistoryValues() -> [Double] {
        return drainHistory
    }

    // Durchschnittlicher Verbrauch auf Basis der gemessenen Leistung
    func averageDrainPerHour(capacityWh: Double = 55.0) -> Double? {
        guard !powerSamples.isEmpty else { return nil }

        let avgPower = powerSamples.map { $0.watt }.reduce(0, +) / Double(powerSamples.count)
        let drainPerHour = avgPower * 100.0 / capacityWh

        // Debug
        print("DEBUG: avgPower = \(avgPower) W, drainPerHour = \(drainPerHour) %/h")

        return drainPerHour
    }

    // MARK: - Runtime Tracking

    func addRuntimeSample(isCharging: Bool) {
        if wasCharging && !isCharging {
            lastChargeTime = Date()
        }
        wasCharging = isCharging

        let hours = Date().timeIntervalSince(lastChargeTime) / 3600
        runtimeSamples.append(hours)
        if runtimeSamples.count > maxRuntimeSamples { runtimeSamples.removeFirst() }
    }

    func runtimeHistory() -> [Double] {
        return runtimeSamples
    }

    func hoursSinceLastCharge() -> Double {
        return Date().timeIntervalSince(lastChargeTime) / 3600
    }
}
