//
//  ProfileSettingsViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm
import MobileCoreServices
import Photos
import UIComponents


/**
 * settings
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileSettingsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var userImage: UIImageView!
    
    /// user
    var user: Variable<User>!
    
    /// embed
    private var embed: ProfileSettingsTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addBackButton()
        user.asObservable().subscribe(onNext: { [weak self] value in
            self?.userImage.load(url: value.image)
        }).disposed(by: rx.bag)
    }

    /// photo button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func changePhotoTapped(_ sender: Any) {
        pickPhoto()
    }
    
    /// button button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func editTapped(_ sender: Any) {
        embed.isEditMode = !embed.isEditMode
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: embed.isEditMode ? .save : .edit, target: self, action: #selector(editTapped(_:)))
    }
    
    /// segue handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ProfileSettingsTableViewController {
            embed = controller
            controller.user = user
        }
    }
}

// MARK: - image select extension
extension ProfileSettingsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    // MARK: image picker
    /**
     picker cancelled
     
     - parameter picker: the picker
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
     Image selected/captured
     
     - parameter picker: the picker
     - parameter info:   the info
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var resizedImage: UIImage?
        if let mediaType = info[UIImagePickerControllerMediaType] {
            if (mediaType as AnyObject).description == kUTTypeImage as String {
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    resizedImage = image.compressIfNeeded()
                }
            }
        }
        if let resizedImage = resizedImage {
            picker.dismiss(animated: true, completion: {
                try? self.user.value.realm?.write {
                    self.user.value.avatar = resizedImage
                }
            })
        }
    }
}

/**
 * Embed
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ProfileSettingsTableViewController: UITableViewController {
    
    /// outlets
    @IBOutlet weak var switchEmails: UISwitch!
    @IBOutlet weak var switchAdmission: UISwitch!
    @IBOutlet weak var nameField: UnderlineTextField!
    @IBOutlet weak var emailField: UnderlineTextField!
    @IBOutlet weak var passwordField: UnderlineTextField!
    
    /// user
    var user: Variable<User>!
    
    /// edit mode
    var isEditMode = false {
        didSet {
            nameField.isUserInteractionEnabled = isEditMode
            emailField.isUserInteractionEnabled = isEditMode
            passwordField.isUserInteractionEnabled = isEditMode
            nameField.underlineColor = isEditMode ? .textDark : .clear
            emailField.underlineColor = isEditMode ? .textDark : .clear
            passwordField.underlineColor = isEditMode ? .textDark : .clear
            
            if !isEditMode { // save
                let user = self.user.value
                try? user.realm?.write {
                    if self.nameField.textValue.trim().isEmpty {
                        self.nameField.text = user.name
                    }
                    else {
                        user.name = self.nameField.textValue
                    }
                    if !self.emailField.textValue.isValidEmail {
                        self.emailField.text = user.email
                    }
                    else {
                        user.email = self.emailField.textValue
                    }
                    self.passwordField.text = user.name // just mock for now
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user.asObservable().subscribe(onNext: { [weak self] value in
            self?.nameField.text = value.name
            self?.emailField.text = value.email
        }).disposed(by: rx.bag)
        switchEmails.isOn = UserDefaults.switchEmails
        switchAdmission.isOn = UserDefaults.switchAdmission
    }
    
    /// customize header
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.from(hexString: "ececec")
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.textDark
        header.textLabel?.font = UIFont(name: "OpenSans-Semibold", size: 12)
    }
    
    /// switch handler
    ///
    /// - Parameter sender: the switch
    @IBAction func switchToggled(_ sender: UISwitch) {
        switch sender {
        case switchEmails:
            UserDefaults.switchEmails = switchEmails.isOn
        case switchAdmission:
            UserDefaults.switchAdmission = switchAdmission.isOn
        default:
            ()
        }
    }
    
    
}
