//
//  LineChart.swift
//  DogPanion
//
//  Created by Rick Stoner on 8/10/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class LineChart: UIView {
    
    let lineLayer = CAShapeLayer()
    let circlesLayer = CAShapeLayer()
    let circlesHighlightLayer = CAShapeLayer()
    
    var chartTransform: CGAffineTransform?
    
    var axisLineWidth: CGFloat = 1
    var deltaX: CGFloat = 10
    var deltaY: CGFloat = 10
    var xMax: CGFloat = 100
    var yMax: CGFloat = 100
    var xMin: CGFloat = 0
    var yMin: CGFloat = 0
    
    var data: [CGPoint]? = nil
    
    @IBInspectable var lineWidth: CGFloat = 1
    @IBInspectable var circleSizeMultiplier: CGFloat = 3
    @IBInspectable var axisColor: UIColor = UIColor.white
    @IBInspectable var showInnerLines: Bool = true
    @IBInspectable var labelFontSize: CGFloat = 10
    
    @IBInspectable var showPoints: Bool = true {
        didSet {
            circlesLayer.isHidden = !showPoints
        }
    }
    
    @IBInspectable var circleColor: UIColor = UIColor.green {
        didSet {
            circlesLayer.fillColor = circleColor.cgColor
        }
    }
    
    @IBInspectable var highLightColor: UIColor = UIColor.green {
        didSet {
            circlesHighlightLayer.fillColor = highLightColor.cgColor
        }
    }
    
    @IBInspectable var lineColor: UIColor = UIColor.green {
        didSet {
            lineLayer.strokeColor = lineColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        combinedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        combinedInit()
    }
    
    func combinedInit() {
        layer.addSublayer(lineLayer)
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = lineColor.cgColor
        layer.addSublayer(circlesLayer)
        layer.addSublayer(circlesHighlightLayer)
        circlesLayer.fillColor = circleColor.cgColor
        circlesHighlightLayer.fillColor = highLightColor.cgColor
        layer.borderWidth = 1
        layer.borderColor = axisColor.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = bounds
        circlesLayer.frame = bounds
        circlesHighlightLayer.frame = bounds
        if let d = data{
            setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
            plot(d)
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let t = chartTransform else { return }
        drawAxes(in: context, usingTransform: t)
    }
    
    func setAxisRange(forPoints points: [CGPoint]) {
        guard !points.isEmpty else { return }
        
        let xs = points.map() { $0.x }
        let ys = points.map() { $0.y }
        
        xMax = ceil(xs.max()! / deltaX) * deltaX
        yMax = ceil(ys.max()! / deltaY) * deltaY
        xMin = 0
        yMin = 0
        setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
    }
    
    func drawAxes(in context: CGContext, usingTransform t: CGAffineTransform) {
    context.saveGState()
        
        let thickerLines = CGMutablePath()
        let thinnerLines = CGMutablePath()
    
        let xAxisPoints = [CGPoint(x: xMin, y: 0), CGPoint(x: xMax, y: 0)]
        let yAxisPoints = [CGPoint(x: 0, y: yMin), CGPoint(x: 0, y: yMax)]
    
        thickerLines.addLines(between: xAxisPoints, transform: t)
        thickerLines.addLines(between: yAxisPoints, transform: t)
    
        for x in stride(from: xMin, through: xMax, by: deltaX) {
            let tickPoints = showInnerLines ?
                [CGPoint(x: x, y: yMin).applying(t), CGPoint(x: x, y: yMax).applying(t)] :
                [CGPoint(x: x, y: 0).applying(t), CGPoint(x: x, y: 0).applying(t).adding(y: -5)]
            thinnerLines.addLines(between: tickPoints)
    
            if x != xMin {
                let label = "\(Int(x))" as String
                let labelSize = "\(Int(x))".size(withSystemFontSize: labelFontSize)
                let labelDrawPoint = CGPoint(x: x, y: 0).applying(t)
                    .adding(x: -labelSize.width/2)
                    .adding(y: 1)
    
                label.draw(at: labelDrawPoint,
                           withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: labelFontSize), NSAttributedStringKey.foregroundColor: axisColor])
            }
        }
        for y in stride(from: yMin, through: yMax, by: deltaY) {
    
            let tickPoints = showInnerLines ?
                [CGPoint(x: xMin, y: y).applying(t), CGPoint(x: xMax, y: y).applying(t)] :
                [CGPoint(x: 0, y: y).applying(t), CGPoint(x: 0, y: y).applying(t).adding(x: 5)]
    
    
            thinnerLines.addLines(between: tickPoints)
    
            if y != yMin {
                let label = "\(Int(y))" as String
                let labelSize = "\(Int(y))".size(withSystemFontSize: labelFontSize)
                let labelDrawPoint = CGPoint(x: 0, y: y).applying(t)
                    .adding(x: -labelSize.width - 1)
                    .adding(y: -labelSize.height/2)
    
                label.draw(at: labelDrawPoint,
                           withAttributes:
                    [NSAttributedStringKey.font: UIFont.systemFont(ofSize: labelFontSize),
                     NSAttributedStringKey.foregroundColor: axisColor])
            }
        }
        context.setStrokeColor(axisColor.cgColor)
        context.setLineWidth(axisLineWidth)
        context.addPath(thickerLines)
        context.strokePath()
    
        context.setStrokeColor(axisColor.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(axisLineWidth/2)
        context.addPath(thinnerLines)
        context.strokePath()
    
        context.restoreGState()
    }
    
    func setAxisRange(xMin: CGFloat, xMax: CGFloat, yMin: CGFloat, yMax: CGFloat) {
        self.xMin = xMin
        self.xMax = xMax
        self.yMin = yMin
        self.yMax = yMax
        
        setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
    }
    
    func setTransform(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        
        let xLabelSize = "\(Int(maxX))".size(withSystemFontSize: labelFontSize)
        
        let yLabelSize = "\(Int(maxY))".size(withSystemFontSize: labelFontSize)
        
        let xOffset = xLabelSize.height + 2
        let yOffset = yLabelSize.width + 5
        
        let xScale = (bounds.width - yOffset - xLabelSize.width/2 - 2)/(maxX - minX)
        let yScale = (bounds.height - xOffset - yLabelSize.height/2 - 2)/(maxY - minY)
        
        chartTransform = CGAffineTransform(a: xScale, b: 0, c: 0, d: -yScale, tx: yOffset, ty: bounds.height - xOffset)
        
        setNeedsDisplay()
    }
    
    func plot(_ points: [CGPoint]) {
        lineLayer.path = nil
        circlesLayer.path = nil
        data = nil
        
        guard !points.isEmpty else { return }
        
        self.data = points
        
        if self.chartTransform == nil {
            setAxisRange(forPoints: points)
        }
        
        let linePath = CGMutablePath()
        linePath.addLines(between: points, transform: chartTransform!)
        lineLayer.path = linePath
        if showPoints {
            circlesLayer.path = circles(atPoints: points, withTransform: chartTransform!, circleSize: nil)
        }
    }
    
    func circles(atPoints points: [CGPoint], withTransform t: CGAffineTransform, circleSize: CGFloat?) -> CGPath {
        
        let path = CGMutablePath()
        let radius = circleSize == nil ? lineLayer.lineWidth * circleSizeMultiplier/2 : lineLayer.lineWidth * circleSize!/2
        for i in points {
            let p = i.applying(t)
            let rect = CGRect(x: p.x - radius, y: p.y - radius, width: radius * 2, height: radius * 2)
            path.addEllipse(in: rect)
            
        }
        return path
    }
    
}
