//
//  LoadingView.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/30/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit

/**
 * Class for a general loading view (for api calls).
 *
 * - author: TCCODER
 * - version: 1.0
 */
class LoadingView: UIView {
    
    /// loading indicator
    var activityIndicator: UIActivityIndicatorView!
    
    /// flag: true - the view is terminated, false - else
    var terminated = false
    
    /// flag: true - the view is shown, false - else
    var didShow = false
    
    /// the reference to the parent view
    var parentView: UIView?
    
    /// Oy shift added to the loading indicator
    private let yShift: CGFloat

    /// the reference to last loading view
    static var lastLoadingView: LoadingView?
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - parentView: the parent view
    ///   - dimming: true - need to add semitransparent overlay, false - just loading indicator
    ///   - yShift: Oy shift added to the loading indicator
    init(parentView: UIView?, dimming: Bool = true, yShift: CGFloat = 0) {
        self.yShift = yShift
        super.init(frame: parentView?.bounds ?? UIScreen.main.bounds)
        
        self.parentView = parentView
        
        setupUI(dimming: dimming)
    }
    
    /**
     Required initializer
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Adds loading indicator and changes colors
     
     - parameter dimming: true - need to add semitransparent overlay, false - just loading indicator
     */
    private func setupUI(dimming: Bool) {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.center
        activityIndicator.frame.origin.y += yShift
        self.addSubview(activityIndicator)
        
        if dimming {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        else {
            activityIndicator.activityIndicatorViewStyle = .gray
            self.backgroundColor = UIColor.clear
        }
        self.alpha = 0.0
    }
    
    /**
     Removes the view from the screen
     */
    func terminate() {
        if LoadingView.lastLoadingView == self {
            LoadingView.lastLoadingView = nil
        }
        terminated = true
        if !didShow { return }
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
        }, completion: { success in
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
        })
    }
    
    /**
     Show the view
     
     - returns: self
     */
    func show() -> LoadingView {
        didShow = true
        LoadingView.lastLoadingView = self
        if !terminated {
            if let view = parentView {
                view.addSubview(self)
                return self
            }
            UIApplication.shared.delegate!.window!?.addSubview(self)
        }
        return self
    }
    
    /**
     Change alpha after the view is shown
     */
    override func didMoveToSuperview() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0.75
        }
    }
}
