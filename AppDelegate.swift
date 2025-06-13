import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    enum GraphMode { case watt, drain }

    var statusItem: NSStatusItem?
    var popover: NSPopover?
    private var graphView: GraphView?
    private var runtimeGraph: GraphView?
    private var runtimeLabel: NSTextField?
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

            if let charging = BatteryReader.shared.isCharging() {
                BatteryHistory.shared.addRuntimeSample(isCharging: charging)
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

            if let label = self.runtimeLabel {
                let hours = BatteryHistory.shared.hoursSinceLastCharge()
                label.stringValue = String(format: "Seit letzter Ladung: %.1f h", hours)
            }

            self.updateGraphIfNeeded()
        }
    }

    @objc func togglePopover() {
        if popover == nil {
            let rect = NSRect(x: 0, y: 0, width: 300, height: 220)
            let viewController = NSViewController()
            let container = NSView(frame: rect)

            let segment = NSSegmentedControl(labels: ["Watt", "%/h"], trackingMode: .selectOne, target: self, action: #selector(changeGraphMode))
            segment.frame = NSRect(x: 10, y: rect.height - 30, width: 120, height: 20)
            segment.selectedSegment = 0
            container.addSubview(segment)
            self.segment = segment

            let label = NSTextField(labelWithString: "")
            label.alignment = .center
            label.frame = NSRect(x: 10, y: 5, width: rect.width - 20, height: 20)
            container.addSubview(label)
            self.runtimeLabel = label

            let runtimeGraphRect = NSRect(x: 0, y: 30, width: rect.width, height: 40)
            let runtime = GraphView(frame: runtimeGraphRect)
            container.addSubview(runtime)
            self.runtimeGraph = runtime

            let graphRect = NSRect(x: 0, y: 75, width: rect.width, height: rect.height - 110)
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

        runtimeGraph?.values = BatteryHistory.shared.runtimeHistory()
    }

    private func updateGraphIfNeeded() {
        guard let popover = popover, popover.isShown else { return }
        updateGraph()
        if let label = runtimeLabel {
            let hours = BatteryHistory.shared.hoursSinceLastCharge()
            label.stringValue = String(format: "Seit letzter Ladung: %.1f h", hours)
        }
    }
}
