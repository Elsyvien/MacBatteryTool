import Cocoa

class GraphView: NSView {
    /// Values to be displayed. Setting them will trigger a redraw.
    var values: [Double] = [] {
        didSet { needsDisplay = true }
    }

    /// Optional maximum value for the Y-axis. If `nil` the largest sample value
    /// will be used. The graph baseline includes zero and negative values.
    var maxValue: Double?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    override var isOpaque: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard values.count > 1 else { return }

        let path = NSBezierPath()

        // Scale from the minimum to the maximum but always include zero
        let dataMin = values.min() ?? 0
        let dataMax = values.max() ?? 0
        let minVal = min(0, dataMin)
        let maxVal = maxValue ?? dataMax
        let range = max(maxVal - minVal, 1)

        let margin: CGFloat = 2
        let availableWidth = bounds.width - margin * 2

        for (index, value) in values.enumerated() {
            let x = margin + availableWidth * CGFloat(index) / CGFloat(values.count - 1)
            let yRatio = CGFloat((value - minVal) / range)
            let y = bounds.height * yRatio
            let point = NSPoint(x: x, y: y)
            if index == 0 {
                path.move(to: point)
            } else {
                path.line(to: point)
            }
        }

        // Light gradient fill for nicer visuals
        let fillPath = path.copy() as! NSBezierPath
        fillPath.line(to: NSPoint(x: margin + availableWidth, y: 0))
        fillPath.line(to: NSPoint(x: margin, y: 0))
        fillPath.close()
        if let gradient = NSGradient(starting: NSColor.systemBlue.withAlphaComponent(0.4),
                                     ending: NSColor.systemBlue.withAlphaComponent(0.05)) {
            gradient.draw(in: fillPath, angle: -90)
        }

        NSColor.systemBlue.setStroke()
        path.lineWidth = 1.5
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        path.stroke()
    }
}