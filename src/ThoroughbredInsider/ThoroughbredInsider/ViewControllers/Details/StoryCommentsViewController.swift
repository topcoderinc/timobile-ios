//
//  StoryCommentsViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import RealmSwift
import RxRealm
import UIComponents
import IQKeyboardManagerSwift

/**
 * Details comments screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryCommentsViewController: UIViewController {
    
    /// story
    var story: StoryDetails!
    
    /// outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var fakeInputView: FakeInputView!
    @IBOutlet var textfieldView: UIView!
    @IBOutlet weak var keyboardTF: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textfieldBgView: UIView!
    
    /// viewmodel
    var vm = TableViewModel<Comment, CommentCell>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        vm.configureCell = { [weak self] index, item, _, cell in
            cell.configure(item)
            cell.onDelete = {
                self?.vm.entries.value.remove(at: index)
            }
        }
        vm.bindData(to: tableView)
        loadData()
        
        setupEditComment()
        startObservingKeyboardEvents()
    }
    
    /// cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// View will appear
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.sharedManager().enable = false
        fakeInputView.becomeFirstResponder()
    }
    
    /// view will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fakeInputView.resignFirstResponder()
        IQKeyboardManager.sharedManager().enable = true
    }
    
    /// setup for add comment
    private func setupEditComment() {
        fakeInputView.accessoryView = textfieldView
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 8.5, height: 30))
        emptyView.backgroundColor = .clear
        keyboardTF.leftView = emptyView
        keyboardTF.leftViewMode = .always
        
        keyboardTF.rx.text.orEmpty.map { !$0.trim().isEmpty }
            .bind(to: sendButton.rx.isEnabled)
            .disposed(by: rx.bag)
    }
    
    /// Load data
    private func loadData() {
        noDataLabel.isHidden = true
        RestDataSource.getStoryComments(id: story.id)
            .showLoading(on: view)
            .subscribe(onNext: { [weak self] value in
                self?.vm.entries.value.append(contentsOf: value)
                self?.noDataLabel.isHidden = self?.vm.entries.value.isEmpty == false
            }).disposed(by: rx.bag)
    }
    
    /// cancel editing tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// send tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func sendTapped(_ sender: Any) {
        keyboardTF.resignFirstResponder()
        fakeInputView.resignFirstResponder()
        let comment = Comment.create()
        comment.timestamp = Date().timeIntervalSince1970
        comment.text = keyboardTF.textValue
        vm.entries.value.insert(comment, at: 0)
        noDataLabel.isHidden = true
        keyboardTF.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025) {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }

    // MARK: - keyboard
    
    /// tap on table handler
    func dismissKeyboard() {
        if keyboardTF.isFirstResponder {
            keyboardTF.resignFirstResponder()
        }
    }
    
    /// observe keyboard
    fileprivate func startObservingKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardDidHide(_:)), name:NSNotification.Name.UIKeyboardDidHide, object:nil)
    }
    
    /// keyboard will show
    ///
    /// - Parameter notification: the notification
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] {
                let keyboardHeight = (keyboardFrame as AnyObject).cgRectValue.size.height
                tableView.contentInset.bottom = keyboardHeight
                if tableView.contentSize.height - tableView.contentOffset.y > tableView.frame.height - keyboardHeight {
                    tableView.contentOffset.y = min(tableView.contentOffset.y + keyboardHeight, tableView.contentSize.height - tableView.frame.height + keyboardHeight)
                }
            }
        }
    }
    
    /// keyboard will hide
    ///
    /// - Parameter notification: the notification
    @objc func keyboardWillHide(_ notification: NSNotification) {
        tableView.contentInset.bottom = textfieldView.bounds.height
    }
    
    /// keyboard did hide
    ///
    /// - Parameter notification: the notification
    @objc func keyboardDidHide(_ notification: NSNotification) {
        tableView.contentInset.bottom = 44
    }
    
}

/**
 * Comment cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class CommentCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    /// current Comment
    var item: Comment!
    
    /// delete handler
    var onDelete: (()->())?
    
    /// configures cell
    ///
    /// - Parameter
    ///   - comment: the comment
    func configure(_ comment: Comment) {
        item = comment
        nameLabel.text = comment.name
        messageLabel.text = comment.text
        userImage.load(url: comment.image)
        timeLabel.text = Date(timeIntervalSince1970: comment.timestamp).timeAgo()
    }
    
    /// delete button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func deleteTapped(_ sender: Any) {
        onDelete?()
    }
    
}


/**
 * Fake input view to allow for editing in same view as input accessory
 *
 * - author: TCCODER
 * - version: 1.0
 */
class FakeInputView: UIView {
    
    /// can become first responder
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    /// the accessory view
    var accessoryView: UIView?
    
    /// input accessory
    override var inputAccessoryView: UIView? {
        return accessoryView
    }
    
}


