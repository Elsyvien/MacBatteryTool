import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🔋 Lade..."

        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            if let currentPercent = BatteryReader.shared.readPercentage() {
                BatteryHistory.shared.addSample(percentage: currentPercent)
            }

            var output = ""

            if let watt = BatteryReader.shared.readWatt() {
                let symbol = BatteryReader.shared.rating(for: watt)
                output += String(format: "⚡ %.2f W %@", watt, symbol)
            }

            if let avgDrain = BatteryHistory.shared.averageDrainPerHour() {
                output += String(format: " | %.1f %%/h", avgDrain)
            }

            self.statusItem?.button?.title = output.isEmpty ? "⚠️ n/a" : output
        }
    }
}
