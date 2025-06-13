import Foundation

struct BatterySample {
    let time: Date
    let percentage: Int
}

final class BatteryHistory {
    static let shared = BatteryHistory()

    private var samples: [BatterySample] = []

    func addSample(percentage: Int) {
        let sample = BatterySample(time: Date(), percentage: percentage)
        samples.append(sample)
        if samples.count > 5 { samples.removeFirst() }
    }

    func averageDrainPerHour() -> Float? {
        guard let first = samples.first, let last = samples.last, samples.count >= 2 else { return nil }

        let deltaPercent = Float(first.percentage - last.percentage)
        let deltaTime = Float(last.time.timeIntervalSince(first.time)) / 3600.0
        guard deltaTime > 0 else { return nil }

        return deltaPercent / deltaTime
    }
}
