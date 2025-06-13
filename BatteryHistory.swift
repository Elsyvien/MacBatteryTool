import Foundation

struct BatterySample {
    let time: Date
    let charge: Int
    let max: Int
}

final class BatteryHistory {
    static let shared = BatteryHistory()

    private var samples: [BatterySample] = []

    func addSample(charge: (current: Int, max: Int)) {
        let sample = BatterySample(time: Date(), charge: charge.current, max: charge.max)
        samples.append(sample)
        if samples.count > 5 { samples.removeFirst() }
    }

    func averageDrainPerHour() -> Double? {
        guard let first = samples.first, let last = samples.last, samples.count >= 2 else { return nil }

        let deltaCharge = Double(first.charge - last.charge)
        let deltaTime = last.time.timeIntervalSince(first.time) / 3600.0
        guard deltaTime > 0 else { return nil }

        return deltaCharge * 100.0 / Double(first.max) / deltaTime
    }
}
