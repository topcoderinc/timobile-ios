//
//  StoryCommentsViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
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
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 */
class StoryCommentsViewController: UIViewController {
    
    /// the related chapter
    var chapter: Chapter!
    
    /// outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var fakeInputView: FakeInputView!
    @IBOutlet var textfieldView: UIView!
    @IBOutlet weak var keyboardTF: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textfieldBgView: UIView!
    
    /// viewmodel
    var vm = InfiniteTableViewModel<Comment, CommentCell>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        vm.noDataLabel = self.noDataLabel
        vm.configureCell = { [weak self] index, item, _, cell in
            cell.configure(item)
            cell.onDelete = {
                guard let sf = self, let index = sf.vm.items.index(of: item) else { return }
                let item = sf.vm.items[index]
                guard item.userId == AuthenticationUtil.sharedInstance.userInfo?.toUser().id else {
                    sf.showAlert("", "You cannot delete other user's comment")
                    return
                }
                RestServiceApi.shared.deleteComment(item, callback: {
                    if let index = sf.vm.items.index(of: item) {
                        sf.vm.items.remove(at: index)
                        if sf.vm.items.count > 0 {
                            sf.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        }
                        else {
                            sf.tableView.reloadData()
                        }
                    }
                }, failure: sf.createGeneralFailureCallback())
            }
        }
        vm.fetchItems = { offset, limit, callback, failure in
            RestServiceApi.shared.searchComments(chapterId: self.chapter.id, trackStoryId: self.chapter.trackStoryId, offset: offset, limit: limit, callback: callback, failure: failure)
        }
        vm.bindData(to: tableView)
        
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
        let comment = Comment()
        comment.id = UUID().uuidString.hashValue
        comment.chapterId = self.chapter.id
        comment.trackStoryId = self.chapter.trackStoryId
        comment.type = "TrackStory"
        comment.text = keyboardTF.textValue
        comment.user = AuthenticationUtil.sharedInstance.userInfo?.toUser()
        vm.items.insert(comment, at: 0)
        if vm.items.count > 0 {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        else {
            self.tableView.reloadData()
        }
        RestServiceApi.shared.createComment(comment, callback: { (updatedComment) in
            if let index = self.vm.items.index(of: comment) {
                self.vm.items.remove(at: index)
                self.vm.items.insert(updatedComment, at: index)
            }
        }, failure: createGeneralFailureCallback())
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
        DispatchQueue.main.async {
            self.fakeInputView.becomeFirstResponder()
        }
    }
    
}

/**
 * Comment cell
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - model object fields changed
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
        nameLabel.text = comment.user.name
        messageLabel.text = comment.text
        userImage.image = #imageLiteral(resourceName: "noProfileIcon")
        userImage.load(url: comment.user.profilePhotoURL, resetImage: false)
        timeLabel.text = comment.createdAt.timeAgo()
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


