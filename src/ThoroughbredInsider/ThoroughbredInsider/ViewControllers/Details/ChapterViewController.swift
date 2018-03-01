//
//  ChapterViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import UIComponents
import AVFoundation
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm

/**
 * StoryChapterViewController and ChapterViewController delegate protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol ChapterViewControllerDelegate {

    /// Notify progres updated
    func progressUpdated()
}

/**
 * chapter screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 */
class ChapterViewController: UIViewController {

    /// outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var raceLabel: UILabel!
    @IBOutlet weak var conentLabel: UILabel!
    
    /// the chapter
    var chapter: Chapter! {
        didSet {
            setupUI()
        }
    }
    /// the total progress
    var progress: StoryProgress?
    /// the story
    var story: Story!
    /// the delegate
    var delegate: ChapterViewControllerDelegate?
    
    /// the player
    private var player: AVPlayer?
    /// and its layer
    private var playerLayer: AVPlayerLayer?
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sliderView.setThumbImage(#imageLiteral(resourceName: "iconChapterSliderPin"), for: .normal)
        setupUI()
        Story.get(with: story.id)
            .subscribe(onNext: { [weak self] (value: Story) in
                self?.raceLabel.text = value.race?.name ?? ""
            }).disposed(by: rx.bag)
        
        scrollView.rx.didScroll.subscribe(onNext: { [weak self] value in
            guard let sf = self else { return }
            sf.updateProgress()
        }).disposed(by: rx.bag)
    }

    /// Update progress
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        updateProgress()
    }

    /// Update progress
    private func updateProgress() {
        let offset = self.scrollView.contentOffset.y + self.scrollView.bounds.height
        let size = self.scrollView.contentSize.height
        let old = self.sliderView.value
        let new = Float(max(0, min(1, offset / max(1, size))))
        self.sliderView.value = max(old, new)
        let progressValue = max(old, new)
        var progress: ChapterProgress! = self.chapter.progress

        // No progress object
        if progress == nil {
            progress = ChapterProgress()
            progress.chapter = self.chapter
            self.chapter?.progress = progress
        }
        if !progress.completed {
            let wordsRead = Int(round(progressValue * Float(self.chapter.wordsCount)))
            // if completed
            if progressValue >= 1 {
                progress.completed = true
                progress.wordsRead = self.chapter?.wordsCount ?? 0
                self.updateProgress(progress)
            }
            // if not completed
            else {
                if wordsRead > progress.wordsRead {
                    progress.wordsRead = wordsRead
                    progress.completed = false
                    self.updateProgress(progress)
                }
                else { return }
            }
            let isCompleted = progress.completed
            try? progress.realm?.write {
                progress.wordsRead = wordsRead
                progress.completed = isCompleted
            }
        }
    }

    /// Save progress
    ///
    /// - Parameter progress: the progress
    private func updateProgress(_ progress: ChapterProgress) {
        RestServiceApi.shared.updateProgress(progress, storyProgress: self.progress, story: self.story, callback: {
            self.delegate?.progressUpdated()
        }, failure: { error in
            print("ERROR: \(error)")
        })
    }
    
    /// setup UI
    private func setupUI() {
        guard titleLabel != nil && chapter != nil else {
            return
        }
        if chapter.media.isEmpty {
            videoView.isHidden = true
            videoViewHeight.constant = 0
        }
        else {
            videoView.isHidden = false
            videoViewHeight.constant = 200
        }
        titleLabel.text = chapter.title
        conentLabel.text = chapter.content
    }

    /// view will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    /// play button tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func playTapped(_ sender: Any) {
        guard let url = URL(string: chapter.media) else { return }
        createPlayer(mediaURL: url, in: videoImageView)
        playButton.isHidden = true
    }
    
    /// creates a player in view
    ///
    /// - Parameters:
    ///   - mediaURL: media URL
    ///   - playerView: host view
    private func createPlayer(mediaURL: URL, in playerView: UIView) {
        player = AVPlayer(url: mediaURL)
        playerLayer = AVPlayerLayer(player: player!)
        playerLayer?.backgroundColor = UIColor.black.cgColor
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        playerView.layer.addSublayer(playerLayer!)
        playerLayer?.frame = playerView.bounds
        player?.play()
    }
    
    /// setup notifications
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(videoEnded(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    /// video ended handler
    ///
    /// - Parameter notification: the notification
    @objc func videoEnded(_ notification: NSNotification) {
        // checking that we're handling the right player item
        guard let currentItem = player?.currentItem,
            let notificationItem = notification.object as? AVPlayerItem,
            notificationItem == currentItem else { return }
        
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
        playButton.isHidden = false
    }

}
