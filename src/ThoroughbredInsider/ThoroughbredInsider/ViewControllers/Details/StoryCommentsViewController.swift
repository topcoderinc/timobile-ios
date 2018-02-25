//
//  StoryCommentsViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import RealmSwift
import RxRealm
import RxCocoa
import RxSwift
import UIComponents
import IQKeyboardManagerSwift

/**
 * Details comments screen
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
class StoryCommentsViewController: InfiniteTableViewController {
    
    /// story
    var story: StoryDetails!
    
    /// chapter id
    var chapterId = 0
    
    /// outlets
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var fakeInputView: FakeInputView!
    @IBOutlet var textfieldView: UIView!
    @IBOutlet weak var keyboardTF: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textfieldBgView: UIView!
    
    /// viewmodel
    var vm = RealmTableViewModel<Comment, CommentCell>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        vm.configureCell = { [weak self] index, item, _, cell in
            cell.configure(item)
            cell.onDelete = {
                guard let strongSelf = self else { return }
                strongSelf.confirm(action: "Delete comment".localized,
                                   message: "Do you want to delete this comment?".localized,
                                   confirmTitle: "Delete".localized, confirmHandler: {
                                    RestDataSource.delete(comment: item)
                                        .subscribe(onNext: { [weak self] value in
                                            guard let realm = item.realm else {
                                                self?.vm.entries.value.remove(at: index)
                                                return
                                            }
                                            try? realm.write {
                                                realm.delete(item)
                                            }
                                        }).disposed(by: strongSelf.rx.bag)
                }, cancelHandler: nil)
            }
        }
        vm.bindData(to: tableView,
                    sortDescriptors: [SortDescriptor(keyPath: "updatedAt", ascending: false)],
                    predicate: NSPredicate(format: "trackStoryId = %d AND chapterId = %d", story.id, chapterId))
        loadData()
        
        vm.entries.asObservable()
            .map { $0.isEmpty }
            .subscribe(onNext: { [weak self] value in
            self?.noDataLabel.isHidden = !value
        }).disposed(by: rx.bag)
        
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
        let storyId = story.id
        let chapterId = self.chapterId
        setupPager(requestPager: RequestPager<Comment>(request: { (offset, limit) -> Observable<PageResult<Comment>> in
            RestDataSource.getStoryComments(offset: offset, limit: limit, trackStoryId: storyId, chapterId: chapterId)
        }))
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
        comment.text = keyboardTF.textValue
        comment.userId = UserDefaults.loggedUserId
        comment.chapterId = chapterId
        comment.type = Comment.CommentType.chapter.rawValue
        comment.trackStoryId = story.id
        loadData(from: RestDataSource.post(comment: comment))
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
 * - version: 1.1
 * 1.1:
 * - updates for integration
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
        nameLabel.text = comment.user?.name
        messageLabel.text = comment.text
        userImage.load(url: comment.user?.profilePhotoURL ?? "")
        timeLabel.text = comment.updatedAt.timeAgo()
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


