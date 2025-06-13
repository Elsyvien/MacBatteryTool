import Cocoa

class GraphView: NSView {
    var values: [Double] = [] {
        didSet { needsDisplay = true }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.windowBackgroundColor.setFill()
        dirtyRect.fill()
        guard values.count > 1 else { return }
        let path = NSBezierPath()
        let maxVal = values.max() ?? 0
        let minVal = values.min() ?? 0
        let range = max(maxVal - minVal, 1)
        for (index, value) in values.enumerated() {
            let x = bounds.width * CGFloat(index) / CGFloat(values.count - 1)
            let y = bounds.height * CGFloat((value - minVal) / range)
            let point = NSPoint(x: x, y: y)
            if index == 0 {
                path.move(to: point)
            } else {
                path.line(to: point)
            }
        }
        NSColor.systemBlue.setStroke()
        path.lineWidth = 2
        path.stroke()
    }
}
