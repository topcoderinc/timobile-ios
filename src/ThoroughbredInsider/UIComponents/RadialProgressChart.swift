//
//  RadialProgressChart.swift
//  UIComponents
//
//  Created by TCCODER on 6/11/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * radial chart with 2 progress rings
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable open class RadialProgressChart: UIView {
    
    open override class var layerClass: AnyClass {
        return RadialProgressLayer.self
    }
    
    /// inner progress value
    @IBInspectable open var innerValue: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// outer progress value
    @IBInspectable open var outerValue: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// ring thickness
    @IBInspectable open var ringWidth: CGFloat = 2.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// inner color
    @IBInspectable open var innerRingColor: UIColor = UIColor.tealGreen {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// outer color
    @IBInspectable open var outerRingColor: UIColor = UIColor.from(hexString: "43b02a")! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// outer ring bg color
    @IBInspectable open var outerRingBgColor: UIColor = UIColor.from(hexString: "494949")!.withAlphaComponent(0.2) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// spacing between rings
    @IBInspectable open var ringSpacing: CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// start angle
    let startAngle: CGFloat = -90
    
    /// awake
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        // Helps with pixelation and blurriness on retina devices
        layer.contentsScale = UIScreen.main.scale
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale * 2
        layer.masksToBounds = false
        
        (layer as! RadialProgressLayer).onDraw = { [unowned self] ctx in
            self.drawOuterRingBg(in: ctx)
            self.drawOuterRing(in: ctx)
            self.drawInnerRing(in: ctx)
        }
    }
    
    
    /// override draw to store a texture
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    private func draw(in ctx: CGContext) {
    }

    /// draws outer ring bg
    private func drawOuterRingBg(in ctx: CGContext) {
        let endAngle = 360 - startAngle
        
        let radiusOut: CGFloat = (max(bounds.width,
                                      bounds.height)/2) - ringWidth/2
        
        // draw
        drawRing(in: ctx, startAngle: startAngle, endAngle: endAngle, radius: radiusOut, color: outerRingBgColor)
    }
    
    /// draws outer ring
    private func drawOuterRing(in ctx: CGContext) {
        let endAngle = 360 * outerValue + startAngle
        
        let radiusOut = (max(bounds.width,
                             bounds.height)/2) - ringWidth/2
        
        // draw
        drawRing(in: ctx, startAngle: startAngle, endAngle: endAngle, radius: radiusOut, color: outerRingColor)
    }
    
    /// draws inner ring
    private func drawInnerRing(in ctx: CGContext) {
        let endAngle = 360 * innerValue + startAngle
        
        let radiusIn = max(bounds.width,
                            bounds.height)/2 - ringSpacing - ringWidth*3/2
        
        // draw
        var center = bounds.origin
        center.x += bounds.width/2
        center.y += bounds.height/2
        let path = UIBezierPath(arcCenter: center,
                                radius: radiusIn,
                                startAngle: startAngle.toRads,
                                endAngle: endAngle.toRads,
                                clockwise: true)
        path.addLine(to: center)
        path.close()
        ctx.setFillColor(innerRingColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.drawPath(using: .fill)
    }
    
    /// draws a ring
    private func drawRing(in ctx: CGContext, startAngle: CGFloat = -90, endAngle: CGFloat, radius: CGFloat, color: UIColor) {
        var center = bounds.origin
        center.x += bounds.width/2
        center.y += bounds.height/2
        let path = UIBezierPath(arcCenter: center,
                                     radius: radius,
                                     startAngle: startAngle.toRads,
                                     endAngle: endAngle.toRads,
                                     clockwise: true)
        
        // Draw path
        ctx.setLineWidth(ringWidth)
        ctx.setLineJoin(.round)
        ctx.setLineCap(.round)
        ctx.setStrokeColor(color.cgColor)
        ctx.addPath(path.cgPath)
        ctx.drawPath(using: .stroke)
    }
    
}

/**
 * custom layer
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RadialProgressLayer: CALayer {
    
    var onDraw: ((CGContext) -> ())?
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        onDraw?(ctx)
    }
    
}

/// converts angle value from degrees to radians
extension CGFloat {
    var toRads: CGFloat { return self * CGFloat.pi / 180 }
}
