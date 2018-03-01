//
//  UIExtensions.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import CoreLocation

/// the number of meters in 1 mile
let METERS_PER_MILE: Double = 1609.344

/**
 Shows an alert with the title and message.

 - parameter title:      the title
 - parameter message:    the message
 - parameter completion: the completion callback
 */
func showAlert(_ title: String, message: String, completion: (()->())? = nil) {
    UIViewController.current?.showAlert(title, message, completion: completion)
}

/**
 Show alert with given error message

 - parameter errorMessage: the error message
 - parameter completion:   the completion callback
 */
func showError(errorMessage: String, completion: (()->())? = nil) {
    showAlert(NSLocalizedString("Error", comment: "Error alert title"), message: errorMessage, completion: completion)
}

/**
 Show alert message about stub functionalify
 */
func showStub() {
    showAlert("Stub", message: "This feature will be implemented in future")
}

/// Delays given callback invocation
///
/// - Parameters:
///   - delay: the delay in seconds
///   - callback: the callback to invoke after 'delay' seconds
func delay(_ delay: TimeInterval, callback: @escaping ()->()) {
    let delay = delay * Double(NSEC_PER_SEC)
    let popTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC);
    DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
        callback()
    })
}

// MARK: - shortcut methods for UIViewController
extension UIViewController {
    
    /// instantiates initial viewController from storyboard
    ///
    /// - Returns: viewController if exists
    func createInitialViewController(storyboard: Storyboards) -> UIViewController? {
        return storyboard.instantiate.instantiateInitialViewController()
    }
    
    /// instantiates viewController from storyboard
    ///
    /// - Parameter viewController: viewController Type
    /// - Parameter storyboard: storyboard or nil to use current one
    /// - Returns: viewController if exists
    func create<T: UIViewController>(viewController: T.Type, storyboard: Storyboards? = nil) -> T? {
        if let storyboard = storyboard {
            return storyboard.instantiate.instantiateViewController(withIdentifier: viewController.className) as? T
        }
        return self.storyboard?.instantiateViewController(withIdentifier: viewController.className) as? T
    }
    
    /**
     Load child controller inside contentView
     
     - parameter vc: child controller
     - parameter contentView: container view
     */
    func loadChildController(_ vc: UIViewController, inContentView contentView: UIView, insets: UIEdgeInsets = .zero) {
        self.addChildViewController(vc)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vc.view)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(insets.top))-[view]-(\(insets.bottom))-|", options: [], metrics: nil, views: ["view" : vc.view]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(insets.left))-[view]-(\(insets.right))-|", options: [], metrics: nil, views: ["view" : vc.view]))
        
        self.view.layoutIfNeeded()
        
        vc.didMove(toParentViewController: self)
    }
    
    /**
     Unload child controller from its parent
     
     - parameter vc: child controller
     */
    func unloadChildController(_ vc: UIViewController?) {
        if let vc = vc {
            vc.willMove(toParentViewController: nil)
            vc.removeFromParentViewController()
            vc.view.removeFromSuperview()
        }
    }
    
    /// removes self from parent controller
    func removeFromParent() {
        parent?.unloadChildController(self)
    }
    
    /// unloads first child controller if present
    func unloadCurrentChildController() {
        unloadChildController(childViewControllers.first)
    }
    
    /**
     Displays alert with specified title & message

     - parameter title:      the title
     - parameter message:    the message
     - parameter completion: the completion callback
     */
    func showAlert(_ title: String, _ message: String, completion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default,
                                      handler: { (_) -> Void in
                                        alert.dismiss(animated: true, completion: nil)
                                        DispatchQueue.main.async {
                                            completion?()
                                        }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Show error alert
     
     - parameter message: the message of the error alert
     */
    func showErrorAlert(message: String) {
        showAlert("Error".localized, message)
    }
    
    /**
     Show stub alert
     */
    func showStub() {
        showAlert("Stub".localized, "Not implemented yet.".localized)
    }
    
    /// shows alert to confirm an user action
    ///
    /// - Parameters:
    ///   - action: action title
    ///   - message: confirmation message
    ///   - confirmTitle: confirmation button title, default "OK"
    ///   - cancelTitle: cancel button title, default "Cancel"
    ///   - confirmHandler: confirmation handler
    ///   - cancelHandler: optional cancel handler
    func confirm(action: String, message: String, confirmTitle: String = "OK".localized, cancelTitle: String = "Cancel".localized, confirmHandler: @escaping ()->(), cancelHandler: (()->())?) {
        let alert = UIAlertController(title: action, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive, handler: { _ in
            confirmHandler()
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
            cancelHandler?()
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    /// view controller to present on
    static var current: UIViewController? {
        var vc = UIApplication.shared.delegate?.window??.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        return vc
    }

    /**
     Get currently opened view controller.

     - returns: the top visible view controller
     */
    class func getCurrentViewController() -> UIViewController? {
        return current
    }
    
    /// wraps view controller in a navigation controller
    var wrappedInNavigationController: UINavigationController {
        let navigation = UINavigationController(rootViewController: self)
        return navigation
    }
    
    /// just removes the line
    func removeNavigationBarLine() {
        for parent in navigationController?.view.subviews ?? [] {
            for child in parent.subviews {
                for view in child.subviews {
                    if view is UIImageView && view.frame.height == 0.5 {
                        view.alpha = 0
                    }
                }
            }
        }
    }
    
    /// makes navigation bar fully transparent
    func makeTransparentNavigationBar() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    /// reverts transparent navbar back to normal
    func revertTransparentNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = false
    }
    
    /// setups back button according to design
    func addBackButton() {
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "navIconBack"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItems = [back]
    }
    
    /// common action
    @IBAction func goBack() {
        navigationController?.popViewController(animated: true)
    }
 
    
    /// picks an image with image picker controller
    ///
    /// - Parameter callback: callback with image
    func pickImage(callback: @escaping (UIImage?) -> ()) {
        let vc = UIImagePickerController()
        vc.rx.didFinishPickingMediaWithInfo.subscribe(onNext: { [weak self] value in
            let image = value[UIImagePickerControllerOriginalImage] as? UIImage
            callback(image)
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.bag)
        vc.rx.didCancel.subscribe(onNext: { [weak self] value in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.bag)
        present(vc, animated: true, completion: nil)
    }
    
    /// Update navigation stack to contain only first and last view controllers
    func cleanNavigationStack(maxScreens: Int = 2) {
        if let list = self.navigationController?.viewControllers {
            if list.count > maxScreens {
                let updatedStack = Array(list[0..<maxScreens])
                self.navigationController?.setViewControllers(updatedStack, animated: false)
            }
        }
    }

    /// Logout
    ///
    /// - Parameters:
    ///   - force: true - will logout without confirmation
    ///   - callback: the callback to invoke when logout complete
    func logout(force: Bool = false, callback: (()->())? = nil) {
        let callback = {
            let cleanUpCallback: ()->() = {
                AuthenticationUtil.sharedInstance.cleanUp()
                self.dismiss(animated: true, completion: callback)
            }
            RestServiceApi.shared.logout(callback: cleanUpCallback, failure: { error in
                print("ERROR: \(error)")
                cleanUpCallback()
            })
        }
        if force {
            callback()
        }
        else {
            confirm(action: "Logout".localized, message: "Are you sure you want to logout?".localized, confirmHandler: callback, cancelHandler: nil)
        }
    }

    /// Show loading view
    ///
    /// - Parameter view: the parent view
    /// - Returns: the loading view
    func showLoadingView(_ view: UIView? = nil) -> LoadingView? {
        return LoadingView(parentView: view ?? UIViewController.getCurrentViewController()?.view ?? self.view).show()
    }

    /// Create general failure callback that show alert with error message over the current view controller
    ///
    /// - Parameter loadingView: the loading view parameter
    /// - Returns: FailureCallback instance
    func createGeneralFailureCallback(_ loadingView: LoadingView? = nil) -> FailureCallback {
        return { (errorMessage) -> () in
            self.showAlert(NSLocalizedString("Error", comment: "Error"), errorMessage)
            loadingView?.terminate()
        }
    }
    
}

// MARK: - label extensions
extension UILabel {
    
    /**
     Updates line height in the label
     
     - parameter lineHeight: the lineHeight
     */
    func setLineHeight(_ lineHeight: CGFloat) {
        let paragrahStyle = NSMutableParagraphStyle()
        paragrahStyle.minimumLineHeight = lineHeight
        paragrahStyle.alignment = textAlignment
        paragrahStyle.hyphenationFactor = 1
        let attributedString = NSMutableAttributedString(string: text ?? "", attributes: [
            NSAttributedStringKey.paragraphStyle: paragrahStyle,
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.font: UIFont(name: font.fontName, size: font.pointSize)!
            ])
        attributedText = attributedString
    }
}


// MARK: - table view extensions
extension UITableView {
    
    /// deselects selected row
    ///
    /// - Parameter animated: animated or not
    func deselectSelected(animated: Bool = true) {
        if let indexPath = indexPathForSelectedRow {
            deselectRow(at: indexPath, animated: animated)
        }
    }
    
    /**
     Get cell of given class for indexPath
     
     - parameter indexPath: the indexPath
     - parameter cellClass: a cell class
     
     - returns: a reusable cell
     */
    func getCell<T: UITableViewCell>(_ indexPath: IndexPath, ofClass cellClass: T.Type) -> T {
        return self.dequeueReusableCell(withIdentifier: cellClass.className, for: indexPath) as! T
    }
    
}

// MARK: - collection view extensions
extension UICollectionView {
    
    /**
     Get cell of given class for indexPath
     
     - parameter indexPath: the indexPath
     - parameter cellClass: a cell class
     
     - returns: a reusable cell
     */
    func getCell<T: UICollectionViewCell>(_ indexPath: IndexPath, ofClass cellClass: T.Type) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: cellClass.className, for: indexPath) as! T
    }
    
}

// MARK: - useful extension for textfields
extension UITextField {
    
    /// placeholder color
    var placeholderColor: UIColor {
        get {
            return self.value(forKeyPath: "_placeholderLabel.textColor") as! UIColor
        }
        set {
            self.setValue(newValue, forKeyPath: "_placeholderLabel.textColor")
        }
    }
    
    /// unwrapped text value
    var textValue: String {
        return text ?? ""
    }
    
}

/// iphone <=5 flag
let isIphone5OrLess = UIScreen.main.bounds.height <= 568

/// screen size
let SCREEN_SIZE = UIScreen.main.bounds.size


/**
 * Lets you use fixed space bar button items in IB
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SpaceAdjustmentItem: UIBarButtonItem {
    
    /// replace self with width adjustment item
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        item.width = -8
        return item
    }
    
}

// MARK: - image extensions
extension UIImage {
    
    /**
     compresses image if needed
     
     - returns: compressed image or original
     */
    func compressIfNeeded() -> UIImage {
        let maxImageSize: CGFloat = 512
        if max(self.size.width, self.size.height) <= maxImageSize {
            return self
        } else
        {
            return compressImage(ratio: maxImageSize / max(self.size.width, self.size.height))
        }
    }
    
    /**
     Compresses image size with specified ratio
     
     - parameter ratio: ratio
     
     - returns: compressed image
     */
    func compressImage(ratio: CGFloat) -> UIImage {
        let image = self
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

// MARK: - image view extensions
extension UIImageView {

    /// load image from url
    ///
    /// - Parameters:
    ///   - url: the url
    ///   - resetImage: true - will set nil image before loading
    ///   - callback: the callback used to check if still need to replace the image
    func load(url: String, resetImage: Bool = true, callback: (()->(Bool))? = nil) {
        if resetImage { self.image = nil }
        if url.isEmpty { return }
        if let imageUrl = URL(string: url), !(imageUrl.scheme ?? "").isEmpty {
            UIImage.loadAsync(url, callback: { (image) in
                if let image = image, callback?() ?? true {
                    self.image = image
                }
            })
        }
        else {
            image = UIImage(contentsOfFile: FileUtil.getLocalFileURL(url).path)
        }
    }
    
}

/// type alias for image request callback
typealias ImageCallback = (UIImage?)->()

/**
 * Class for storing in-memory cached images
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class UIImageCache {

    /// Cache for images
    var CachedImages = [String: (UIImage?, [ImageCallback])]()

    /// the singleton
    class var sharedInstance: UIImageCache {
        struct Singleton { static let instance = UIImageCache() }
        return Singleton.instance
    }
}

/**
 * Extends UIImage with a shortcut method.
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UIImage {

    /// Get image from given view
    ///
    /// - Parameter view: the view
    /// - Returns: UIImage
    class func imageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)

        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    /**
     Load image asynchronously

     - parameter url:      image URL
     - parameter callback: the callback to return the image
     */
    class func loadFromURLAsync(_ url: URL, callback: @escaping ImageCallback) {
        let key = url.absoluteString

        // If there is cached data, then use it
        if let data = UIImageCache.sharedInstance.CachedImages[key] {
            if data.1.isEmpty { // Is image already loadded, then use it
                callback(data.0)
            }
            else { // If image is not yet loaded, then add callback to the list of callbacks
                var savedCallbacks: [ImageCallback] = data.1
                savedCallbacks.append(callback)
                UIImageCache.sharedInstance.CachedImages[key] = (nil, savedCallbacks)
            }
            return
        }
        // If the image is first time requested, then load it
        UIImageCache.sharedInstance.CachedImages[key] = (nil, [callback])
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {

            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                DispatchQueue.main.async { () -> Void in
                    guard let data = data, error == nil else { callback(nil); return }
                    if let image = UIImage(data: data) {

                        // Notify all callbacks
                        for callback in UIImageCache.sharedInstance.CachedImages[key]!.1 {
                            callback(image)
                        }
                        UIImageCache.sharedInstance.CachedImages[key] = (image, [])
                        return
                    }
                    else {
                        print("ERROR: Error occured while creating image from the data: \(data) url=\(url)")
                    }
                }
            }) .resume()
        })
    }

    /**
     Load image asynchronously.
     More simple method than loadFromURLAsync() that helps to cover common fail cases
     and allow to concentrate on success loading.

     - parameter urlString: the url string
     - parameter callback:  the callback to return the image
     */
    class func loadAsync(_ urlString: String?, callback: @escaping (UIImage?)->()) {
        if let urlStr = urlString {
            if urlStr.hasPrefix("http") {
                if let url = URL(string: urlStr) {
                    UIImage.loadFromURLAsync(url, callback: { (image: UIImage?) -> () in
                        callback(image)
                    })
                    return
                }
                else {
                    print("ERROR: Wrong URL: \(urlStr)")
                    callback(nil)
                }
            }
                // If urlString is not real URL, then try to load image from assets
            else if let image = UIImage(named: urlStr) {
                callback(image)
            }
        }
        else {
            callback(nil)
        }
    }
}

/**
 * Helpful methods for calculating distance
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension CLLocationCoordinate2D {

    /// Get distance to point
    ///
    /// - Parameter to: the point
    /// - Returns: the distance in miles
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to) / METERS_PER_MILE
    }
}
