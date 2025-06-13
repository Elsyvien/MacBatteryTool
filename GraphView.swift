import Cocoa

class GraphView: NSView {
    /// Values to be displayed. Setting them will trigger a redraw.
    var values: [Double] = [] {
        didSet { needsDisplay = true }
    }

    /// Optional maximum value for the Y-axis. If nil the largest value of
    /// `values` will be used. The graph always starts at 0.
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

        // Start always at zero to avoid misleading scaling
        let minVal: Double = 0
        let maxVal = maxValue ?? (values.max() ?? 0)
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

        // Optional fill under the curve for nicer visuals
        let fillPath = path.copy() as! NSBezierPath
        fillPath.line(to: NSPoint(x: margin + availableWidth, y: 0))
        fillPath.line(to: NSPoint(x: margin, y: 0))
        fillPath.close()
        NSColor.systemBlue.withAlphaComponent(0.3).setFill()
        fillPath.fill()

        NSColor.systemBlue.setStroke()
        path.lineWidth = 2
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        path.stroke()
    }
}
