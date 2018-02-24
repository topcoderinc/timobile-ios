//
//  UIExtensions.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import AlamofireImage

/// convenience shortcut
func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
    UIViewController.current?.showAlert(title: title, message: message, handler: handler)
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
     Show alert
     
     - parameters:
     - title: the title of the alert
     - message: the message of the alert
     */
    func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default, handler: handler))
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     Show error alert
     
     - parameter message: the message of the error alert
     */
    func showErrorAlert(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        showAlert(title: "Error".localized, message: message, handler: handler)
    }
    
    /**
     Show stub alert
     */
    func showStub() {
        showAlert(title: "Stub".localized, message: "Not implemented yet.".localized)
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
 
    /// validates a single text field
    ///
    /// - Parameters:
    ///   - field: text field
    ///   - name: text field name
    /// - Returns: validation status
    func validateFieldNotEmpty(field: UITextField) -> Bool {
        guard !field.textValue.isEmpty else {
            showErrorAlert(message: "\(field.placeholder ?? "Field") cannot be empty".localized) { _ in
                field.becomeFirstResponder()
            }
            return false
        }
        return true
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
    /// - Parameter url: url
    func load(url: String) {
        if let imageUrl = URL(string: url), !(imageUrl.scheme ?? "").isEmpty {
            af_setImage(withURL: imageUrl)
        }
        else {
            image = UIImage(contentsOfFile: FileUtil.getLocalFileURL(url).path)
        }
    }
    
}
