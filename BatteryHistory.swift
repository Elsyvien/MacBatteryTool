import Foundation

struct BatterySample {
    let time: Date
    let charge: Int
    let max: Int
}

struct WattSample {
    let time: Date
    let watt: Double
}

final class BatteryHistory {
    static let shared = BatteryHistory()

    private var samples: [BatterySample] = []
    private var wattSamples: [WattSample] = []
    private let maxSamples = 30  // Erhöhe den Puffer auf 30 für längeren Verlauf
    private let maxWattSamples = 60

    // Neuen Messwert hinzufügen
    func addSample(charge: (current: Int, max: Int)) {
        let sample = BatterySample(time: Date(), charge: charge.current, max: charge.max)
        samples.append(sample)
        if samples.count > maxSamples { samples.removeFirst() }
    }

    // Watt-Messwert hinzufügen
    func addWattSample(_ watt: Double) {
        let sample = WattSample(time: Date(), watt: watt)
        wattSamples.append(sample)
        if wattSamples.count > maxWattSamples { wattSamples.removeFirst() }
    }

    // Aktuelle Verlaufsliste der Wattwerte
    func wattHistory() -> [Double] {
        return wattSamples.map { $0.watt }
    }

    // Durchschnittlicher Entladeverbrauch in % pro Stunde
    func averageDrainPerHour() -> Double? {
        guard let first = samples.first, let last = samples.last, samples.count >= 2 else {
            print("Nicht genug Daten: \(samples.count) Samples")
            return nil
        }

        let deltaCharge = Double(first.charge - last.charge)
        let deltaTime = last.time.timeIntervalSince(first.time) / 3600.0 // Stunden

        print("DEBUG: first.charge = \(first.charge), last.charge = \(last.charge)")
        print("DEBUG: deltaCharge = \(deltaCharge)")
        print("DEBUG: deltaTime (h) = \(deltaTime)")

        guard deltaTime > 0 else {
            print("Zeitspanne zu klein.")
            return nil
        }

        let drainPerHour = deltaCharge * 100.0 / Double(first.max) / deltaTime

        print("DEBUG: drainPerHour = \(drainPerHour) %/h")

        return drainPerHour
    }
}
