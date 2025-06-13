import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var detailWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🔋 Lade..."
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(showDetails)

        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            if let charge = BatteryReader.shared.readCharge() {
                BatteryHistory.shared.addSample(charge: charge)
            }

            var output = ""

            if let watt = BatteryReader.shared.readWatt() {
                BatteryHistory.shared.addWattSample(watt)
                let symbol = BatteryReader.shared.rating(for: watt)
                output += String(format: "⚡ %.2f W %@", watt, symbol)
            }

            if let avgDrain = BatteryHistory.shared.averageDrainPerHour() {
                output += String(format: " | %.1f %%/h", Double(avgDrain))
            }

            self.statusItem?.button?.title = output.isEmpty ? "⚠️ n/a" : output
            self.updateGraphIfNeeded()
        }
    }

    @objc func showDetails() {
        let history = BatteryHistory.shared.wattHistory()
        if detailWindow == nil {
            let rect = NSRect(x: 0, y: 0, width: 300, height: 150)
            detailWindow = NSWindow(contentRect: rect,
                                   styleMask: [.titled, .closable],
                                   backing: .buffered,
                                   defer: false)
            detailWindow?.isReleasedWhenClosed = false
            detailWindow?.title = "Watt Verlauf"
            detailWindow?.contentView = GraphView(frame: rect)
        }
        if let graph = detailWindow?.contentView as? GraphView {
            graph.values = history
        }
        detailWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func updateGraphIfNeeded() {
        guard let window = detailWindow, window.isVisible,
              let graph = window.contentView as? GraphView else { return }
        graph.values = BatteryHistory.shared.wattHistory()
    }
}
