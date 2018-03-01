//
//  StoryDetailsViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm

/// option: true - will show Story summary in Additional Task description (as Android app does),
///         false - will show description from Additional Task response
let OPTION_SHOW_SUMMARY_IN_ADDITIONAL_TASK = false

/**
 * Story details screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 */
class StoryDetailsViewController: UIViewController, ChapterViewControllerDelegate {

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
    @IBOutlet weak var additionalRewardHeight: NSLayoutConstraint!
    @IBOutlet weak var additionalRewardLabel: UILabel!
    @IBOutlet weak var rewardsButton: UIButton!
    @IBOutlet weak var additionalRewardTitleLabel: UILabel!
    @IBOutlet weak var additionalRewardDescriptionLabel: UILabel!
    @IBOutlet weak var takeSelfieButton: UIButton!
    @IBOutlet weak var takeSelfie2Button: UIButton!

    /// the story
    var story: Story!
    
    /// the story
    var details = Variable<Story>(Story())
    
    /// viewmodels
    var tagsVM = CollectionViewModel<Tag, TagCell>()
    var rewardsVM = CollectionViewModel<Card, RewardCell>()

    /// the progress data
    private var progress: StoryProgress?

    /// flag: true - details are loaded, false - else
    private var detailsLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addBackButton()

        let loadingView = showLoadingView()
        storyImage.load(url: story.smallImageURL) { ()->Bool in
            return self.storyImage.image == nil
        }
        RestServiceApi.shared.getStory(id: "\(story.id)", callback: { (details) in
            loadingView?.terminate()
            self.details.value = details
            self.detailsLoaded = true
        }, failure: createGeneralFailureCallback(loadingView))

        self.loadProgress()

        details.asObservable().subscribe(onNext: { [weak self] value in
            self?.updateUI(value: value)
        }).disposed(by: rx.bag)
        
        tagsVM.configureCell = { _, value, _, cell in
            cell.titleLabel.text = value.name
        }
        tagsVM.bindData(to: tagsCollection)
        
        rewardsVM.configureCell = { [weak self] _, value, _, cell in
            cell.titleLabel.text = value.name
            if let progress = self?.progress, progress.cardsAndRewardsReceived == true {
                cell.rewardImage.load(url: value.imageURL)
                cell.rewardImage.contentMode = .scaleAspectFill
            }
            else {
                cell.rewardImage.image = #imageLiteral(resourceName: "logoWhite")
                cell.rewardImage.contentMode = .scaleAspectFit
            }
        }
        rewardsVM.bindData(to: rewardsCollection)
    }

    /// Load progress
    private func loadProgress() {
        RestServiceApi.shared.getStoryProgress(for: story, callback: { (progress) in
            self.processProgress(progress)
        }, failure: createGeneralFailureCallback())
    }

    /// Process progress bar
    ///
    /// - Parameter progress: the progress
    private func processProgress(_ progress: StoryProgress) {
        self.progress = progress
        if !progress.completed {    // check if we can mark as completed
            var isCompleted = true
            for c in self.story.chapters.toArray() {
                if !(c.progress?.completed ?? false) {
                    isCompleted = false
                    break
                }
            }
            if isCompleted { // update story progress to completed
                RestServiceApi.shared.completeStory(storyProgress: progress, callback: {
                    self.rewardsCollection.reloadData()
                    self.updateUI()
                }, failure: createGeneralFailureCallback())
            }
        }
        self.rewardsCollection.reloadData()
        self.updateUI()
    }

    /// Update UI
    private func updateUI() {
        self.updateUI(value: detailsLoaded ? self.details.value : self.story)
    }

    /// Update UI
    ///
    /// - Parameter value: details
    private func updateUI(value: Story) {
        storyImage.load(url: value.largeImageURL, resetImage: false)
        titleLabel.text = value.title
        summaryLabel.text = value.getDescription()
        chaptersLabel.text = "\(value.chapters.count) \("chapters".localized)"
        cardsLabel.text = "\(value.cards.count) \("cards".localized)"
        rewardsVM.entries.value = value.cards.toArray()
        tagsVM.entries.value = value.tags.toArray()

        // Progress
        if let progress = self.progress {
            rewardsButton.isEnabled = !progress.cardsAndRewardsReceived && progress.completed
            if progress.cardsAndRewardsReceived {
                rewardsButton.setTitle("Rewards received".uppercased(), for: .normal)
            }
            rewardsButton.alpha = 1
        }
        else {
            rewardsButton.isEnabled = false
            rewardsButton.alpha = 0.5
        }
        bookmarkButton.image = value.bookmarked ? #imageLiteral(resourceName: "navIconStarSelected") : #imageLiteral(resourceName: "navIconStar")

        // Additional task
        takeSelfieButton.isEnabled = false
        takeSelfieButton.alpha = 0.5
        if let progress = progress {
            if progress.additionalTaskCompleted {
                takeSelfieButton.isEnabled = false
                takeSelfieButton.backgroundColor = UIColor.greyish
                takeSelfieButton.setTitleColor(UIColor.white, for: .disabled)
                takeSelfieButton.setTitle("Completed".localized, for: .disabled)
                takeSelfieButton.borderColor = UIColor.clear
            }
            takeSelfieButton.isEnabled = !progress.additionalTaskCompleted
            takeSelfieButton.alpha = 1
        }
        additionalRewardView.isHidden = value.additionalTask == nil
        if let task = value.additionalTask {
            additionalRewardLabel.text = "\(task.points) pts"
            additionalRewardTitleLabel.text = task.name
            additionalRewardDescriptionLabel.text = OPTION_SHOW_SUMMARY_IN_ADDITIONAL_TASK ? story.getDescription() : task.desc
            additionalRewardHeight.constant = 140
        }
        else {
            additionalRewardHeight.constant = 0
        }
        takeSelfie2Button.isUserInteractionEnabled = takeSelfieButton.isEnabled
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
        details.value.bookmarked = bookmark
        try? details.value.realm?.write {
            self.details.value.bookmarked = bookmark
        }
        try? story.realm?.write {
            self.story.bookmarked = bookmark
        }
        updateUI(value: details.value)
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
            vc.progress = self.progress
            vc.delegate = self
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
        vc.progress = self.progress
        vc.delegate = self
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
        if let progress = progress {
            let loadingView = showLoadingView()
            RestServiceApi.shared.receiveRewards(storyProgress: progress, callback: { (storyRewards) in
                loadingView?.terminate()
                self.updateUI()
                let cards: [Card] = storyRewards.userCards.toArray().map{$0.card}
                guard let vc = self.create(viewController: StoryCompleteViewController.self) else { return }
                vc.story = self.details.value
                vc.cards = cards
                self.present(vc, animated: true, completion: nil)

            }, failure: createGeneralFailureCallback(loadingView))
        }
    }

    // MARK: - ChapterViewControllerDelegate

    /// Update progress
    func progressUpdated() {
        loadProgress()
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
                guard let vc = self.create(viewController: SelfieSuccessViewController.self), let additionalTask = self.details.value.additionalTask else { return }
                additionalTask.progressId = self.progress?.id ?? 0
                vc.additionalTask = additionalTask
                vc.image = resizedImage
                vc.onContinue = { [unowned self] in

                    self.progress?.additionalTaskCompleted = true
                    try? self.progress?.realm?.write {
                        self.progress?.additionalTaskCompleted = true
                    }
                    self.updateUI()
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

