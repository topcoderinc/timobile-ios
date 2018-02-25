//
//  ChapterViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import UIComponents
import AVFoundation
import RxCocoa
import RxSwift

/**
 * chapter screen
 *
 * - author: TCCODER
 * - version: 1.0
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
    var chapter = Variable<Chapter!>(nil)
    
    /// the story
    var story: StoryDetails!
    
    /// the player
    private var player: AVPlayer?
    /// and its layer
    private var playerLayer: AVPlayerLayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sliderView.setThumbImage(#imageLiteral(resourceName: "iconChapterSliderPin"), for: .normal)
        Story.get(with: story.id)
            .subscribe(onNext: { [weak self] (value: Story) in
                self?.raceLabel.text = value.racetrack?.name ?? ""
            }).disposed(by: rx.bag)
        
        scrollView.rx.didScroll.subscribe(onNext: { [weak self] value in
            let offset = (self?.scrollView.contentOffset.y ?? 0) + (self?.scrollView.bounds.height ?? 0)
            let size = self?.scrollView.contentSize.height ?? 0
            let old = self?.sliderView.value ?? 0
            let new = Float(max(0, min(1, offset / size)))
            self?.sliderView.value = max(old, new)
            //TODO: throttle & update progress
//            try? self?.chapter?.realm?.write {
//                self?.chapter.current = Int(round(max(old, new) * Float(self?.chapter.total ?? 0)))
//            }
        }).disposed(by: rx.bag)
        
        chapter.asObservable().subscribe(onNext: { [weak self] value in
            self?.setupUI(value)
        }).disposed(by: rx.bag)
    }
    
    /// setup UI
    private func setupUI(_ chapter: Chapter?) {
        guard let chapter = chapter else {
            return
        }
        if chapter.video.isEmpty {
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
        guard let url = URL(string: chapter.value.video) else { return }
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
