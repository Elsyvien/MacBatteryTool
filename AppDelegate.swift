import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    private var graphView: GraphView?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🔋 Lade..."
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(togglePopover)

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

    @objc func togglePopover() {
        let history = BatteryHistory.shared.wattHistory()

        if popover == nil {
            let rect = NSRect(x: 0, y: 0, width: 300, height: 150)
            let viewController = NSViewController()
            let graph = GraphView(frame: rect)
            viewController.view = graph
            viewController.preferredContentSize = rect.size

            let pop = NSPopover()
            pop.behavior = .transient
            pop.contentViewController = viewController

            self.popover = pop
            self.graphView = graph
        }

        graphView?.values = history

        guard let button = statusItem?.button, let popover = popover else { return }
        if popover.isShown {
            popover.performClose(self)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func updateGraphIfNeeded() {
        guard let popover = popover, popover.isShown, let graph = graphView else { return }
        graph.values = BatteryHistory.shared.wattHistory()
    }
}
