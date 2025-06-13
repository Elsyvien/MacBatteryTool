import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    enum GraphMode { case watt, drain }

    var statusItem: NSStatusItem?
    var popover: NSPopover?
    private var graphView: GraphView?
    private var mode: GraphMode = .watt
    private var segment: NSSegmentedControl?

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
                BatteryHistory.shared.addPowerSample(watt)
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
        if popover == nil {
            let rect = NSRect(x: 0, y: 0, width: 300, height: 170)
            let viewController = NSViewController()
            let container = NSView(frame: rect)

            let segment = NSSegmentedControl(labels: ["Watt", "%/h"], trackingMode: .selectOne, target: self, action: #selector(changeGraphMode))
            segment.frame = NSRect(x: 10, y: rect.height - 30, width: 120, height: 20)
            segment.selectedSegment = 0
            container.addSubview(segment)
            self.segment = segment

            let graphRect = NSRect(x: 0, y: 0, width: rect.width, height: rect.height - 35)
            let graph = GraphView(frame: graphRect)
            container.addSubview(graph)

            viewController.view = container
            viewController.preferredContentSize = rect.size

            let pop = NSPopover()
            pop.behavior = .transient
            pop.contentViewController = viewController

            self.popover = pop
            self.graphView = graph
        }

        updateGraph()

        guard let button = statusItem?.button, let popover = popover else { return }
        if popover.isShown {
            popover.performClose(self)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc private func changeGraphMode(_ sender: NSSegmentedControl) {
        mode = sender.selectedSegment == 0 ? .watt : .drain
        updateGraph()
    }

    private func updateGraph() {
        guard let graph = graphView else { return }
        switch mode {
        case .watt:
            graph.values = BatteryHistory.shared.powerHistory()
        case .drain:
            graph.values = BatteryHistory.shared.drainHistoryValues()
        }
    }

    private func updateGraphIfNeeded() {
        guard let popover = popover, popover.isShown else { return }
        updateGraph()
    }
}
