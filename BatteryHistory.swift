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
        if samples.count > 10 { samples.removeFirst() }
    }

    func averageDrainPerHour() -> Double? {
        guard samples.count >= 2 else { return nil }

        var rates: [Double] = []

        for i in 1..<samples.count {
            let s1 = samples[i - 1]
            let s2 = samples[i]
            let deltaPercent = Double(s1.percentage - s2.percentage)
            let deltaTime = s2.time.timeIntervalSince(s1.time) / 3600.0
            if deltaTime > 0 {
                rates.append(deltaPercent / deltaTime)
            }
        }

        guard !rates.isEmpty else { return nil }
        return rates.reduce(0, +) / Double(rates.count)
    }
}
