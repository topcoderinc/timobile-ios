//
//  PagerControl.swift
//  Thoroughbred
//
//  Created by TCCODER on 9/1/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * pager control
 *
 * - author: TCCODER
 * - version: 1.0
 */
@IBDesignable
open class PagerControl: UIView {

    /// base size
    let size: CGFloat = 14
    
    /// selected size
    let selectedSize: CGFloat = 14
    /// circle size
    let circleSize: CGFloat = 7
    
    /// selected page
    @IBInspectable open var selectedColor: UIColor = .darkSkyBlue
    /// normal page
    @IBInspectable open var normalColor: UIColor = UIColor.from(hexString: "7e868c")!
    
    /// selected page
    @IBInspectable open var selected: Int = 0 {
        didSet {
            guard selected >= 0 && selected < count else { return }
            stack.arrangedSubviews.forEach { self.applyStyle(to: $0 as! PagerCircleView) }
            applyStyle(selected: true, to: stack.arrangedSubviews[selected] as! PagerCircleView)
        }
    }
    
    /// number of pages
    @IBInspectable open var count: Int = 5 {
        didSet {
            updateViews()
            setNeedsLayout()
        }
    }
    
    /// stack view
    private var stack: UIStackView!
    private var stackWidth: NSLayoutConstraint!
    
    /// awake
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        let stack = UIStackView(frame: bounds)
        addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackWidth = stack.widthAnchor.constraint(equalToConstant: size * CGFloat(count))
        stackWidth.isActive = true
        stack.distribution = .equalSpacing
        stack.spacing = 0
        self.stack = stack
        
        updateViews()
    }
    
    /// update views
    private func updateViews() {
        while stack.arrangedSubviews.count > count {
            let subview = stack.arrangedSubviews.last!
            stack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        while stack.arrangedSubviews.count < count {
            let view = PagerCircleView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: size, height: size)))
            view.contentMode = .center
            applyStyle(selected: selected == stack.arrangedSubviews.count, to: view)
            stack.addArrangedSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: size).isActive = true
        }
        stackWidth.constant = size * CGFloat(count)
    }
    
    /// applies style
    private func applyStyle(selected: Bool = false, to view: PagerCircleView) {
        if selected {
            view.circle.backgroundColor = selectedColor
            view.circleSize.constant = selectedSize
        }
        else {
            view.circle.backgroundColor = normalColor
            view.circleSize.constant = circleSize
        }
    }

}

/**
 * Circle view
 *
 * - author: TCCODER
 * - version: 1.0
 */
class PagerCircleView: UIImageView {
   
    /// the circle
    var circle: CircleView!
    /// the circle size
    var circleSize: NSLayoutConstraint!
    
    /// initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        circle = CircleView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(circle)
        circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.widthAnchor.constraint(equalTo: circle.heightAnchor).isActive = true
        circleSize = circle.widthAnchor.constraint(equalToConstant: 7)
        circleSize.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
