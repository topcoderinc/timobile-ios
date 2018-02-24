//
//  StoryDetailsViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm

/**
 * Story details screen
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryDetailsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chaptersLabel: UILabel!
    @IBOutlet weak var cardsLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var tagsCollection: UICollectionView!
    @IBOutlet weak var rewardsCollection: UICollectionView!
    @IBOutlet weak var additionalRewardView: UIView!
    @IBOutlet weak var additionalRewardLabel: UILabel!
    @IBOutlet weak var additionalRewardTitleLabel: UILabel!
    @IBOutlet weak var additionalRewardDescriptionLabel: UILabel!
    @IBOutlet weak var rewardsButton: UIButton!
    
    /// the story
    var story: Story!
    
    /// the story
    var details = Variable<StoryDetails>(StoryDetails())
    
    /// viewmodels
    var tagsVM = CollectionViewModel<Tag, TagCell>()
    var rewardsVM = CollectionViewModel<Card, RewardCell>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addBackButton()
        loadData(from: RestDataSource.getStory(id: story.id))
        StoryDetails.get(with: story.id)
            .bind(to: details)
            .disposed(by: rx.bag)
        details.asObservable().subscribe(onNext: { [weak self] value in
            self?.setupUI(value: value)
        }).disposed(by: rx.bag)
        
        tagsVM.configureCell = { _, value, _, cell in
            cell.titleLabel.text = value.value
        }
        tagsVM.bindData(to: tagsCollection)
        
        rewardsVM.configureCell = { [weak self] _, value, _, cell in
            cell.titleLabel.text = value.name
            if self?.details.value.rewardsReceived == true {
                cell.rewardImage.load(url: value.image)
                cell.rewardImage.contentMode = .scaleAspectFill
            }
            else {
                cell.rewardImage.image = #imageLiteral(resourceName: "logoWhite")
                cell.rewardImage.contentMode = .scaleAspectFit
            }
        }
        rewardsVM.bindData(to: rewardsCollection)
    }
    
    /// setup UI
    ///
    /// - Parameter value: details
    private func setupUI(value: StoryDetails) {
        storyImage.load(url: value.largeImageURL)
        titleLabel.text = value.title
        summaryLabel.text = value.summary
        chaptersLabel.text = "\(value.chapters.count) \("chapters".localized)"
        cardsLabel.text = "\(value.cards.count) \("cards".localized)"
        rewardsVM.entries.value = value.cards.toArray()
        tagsVM.entries.value = value.tags.toArray()
        additionalRewardLabel.text = "\(value.additionalTask?.points ?? 0) pts"
        additionalRewardTitleLabel.text = value.additionalTask?.name ?? ""
        additionalRewardDescriptionLabel.text = value.additionalTask?.descr ?? ""
        additionalRewardView.isHidden = value.rewardsReceived
        rewardsButton.isEnabled = value.completed
        bookmarkButton.image = value.bookmarked ? #imageLiteral(resourceName: "navIconStarSelected") : #imageLiteral(resourceName: "navIconStar")
    }

    /// View will appear
    ///
    /// - Parameter animated: the animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        makeTransparentNavigationBar()
    }

    /// View will disappear
    ///
    /// - Parameter animated: the animation flag
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        revertTransparentNavigationBar()
    }
    
    // MARK: - actions
    
    /// bookmark button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func bookmarkTapped(_ sender: Any) {
        let bookmark = !details.value.bookmarked
        try? details.value.realm?.write {
            self.details.value.bookmarked = bookmark
        }
        try? story.realm?.write {
            self.story.bookmarked = bookmark
        }
    }
    
    /// progress button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func progressTapped(_ sender: Any) {
        guard let vc = create(viewController: StoryProgressViewController.self) else { return }
        vc.story = details.value
        vc.onRewardsTap = { [unowned self] in
            self.dismiss(animated: false, completion: {
                self.collectRewardsTapped(self)
            })
        }
        vc.onSelect = { [unowned self] idx in
            guard let vc = self.create(viewController: StoryChapterViewController.self) else { return }
            vc.story = self.details.value
            vc.initial = idx
            self.dismiss(animated: true) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        let delay: TimeInterval = scrollView.contentOffset.y > 0 ? 0.2 : 0
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    /// read button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func readmoreTapped(_ sender: Any) {
        guard let vc = create(viewController: StoryChapterViewController.self) else { return }
        vc.story = details.value
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// selfie button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func takeSelfieTapped(_ sender: Any) {
        pickPhoto()
    }
    
    /// collect rewards button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func collectRewardsTapped(_ sender: Any) {
        guard let vc = create(viewController: StoryCompleteViewController.self) else { return }
        vc.story = details.value
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - image select extension
extension UIViewController {

    /// show options to pick a photo
    func pickPhoto() {
        let alert = UIAlertController(title: nil, message: nil,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Take Photo".localized, style: UIAlertActionStyle.default,
                                      handler: { (action: UIAlertAction!) in
                                        self.showCameraPicker()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo".localized, style: .default,
                                      handler: { (action: UIAlertAction!) in
                                        self.showPhotoLibraryPicker()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /// Show camera capture screen
    func showCameraPicker() {
        self.showPickerWithSourceType(.camera)
    }
    
    /// Show photo picker
    func showPhotoLibraryPicker() {
        showPickerWithSourceType(.photoLibrary)
    }
    
    /**
     Show image picker
     
     - parameter sourceType: the type of the source
     */
    func showPickerWithSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            if let delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate {
                imagePicker.delegate = delegate
            }
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.sourceType = sourceType
            imagePicker.videoQuality = UIImagePickerControllerQualityType.typeMedium
            present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "This feature is supported on real devices only".localized,
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK: - image select extension
extension StoryDetailsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
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
                guard let vc = self.create(viewController: SelfieSuccessViewController.self) else { return }
                vc.image = resizedImage
                vc.onContinue = { [unowned self] in
                    try? self.details.value.realm?.write {
                        self.details.value.rewardsReceived = true
                        self.details.value.completed = true
                    }
                }
                self.present(vc, animated: true, completion: nil)
            })
        }
    }
}

/**
 * tag cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class TagCell: UICollectionViewCell {
    
    ///outlets
    @IBOutlet weak var titleLabel: UILabel!
    
}

/**
 * rewards cell
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RewardCell: UICollectionViewCell {
    
    ///outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rewardImage: UIImageView!
    
}

