import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🔋 Lade..."

    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
        if let watt = BatteryReader.shared.readWatt() {
            let symbol = BatteryReader.shared.rating(for: watt)
            self.statusItem?.button?.title = String(format: "⚡ %.2f W %@", watt, symbol)
        } else {
            self.statusItem?.button?.title = "⚠️  n/a"
            }
        }
    }
}
