//
//  SegmentController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/1/17.
//  Copyright © 2017 topcoder. All rights reserved.
//

import UIKit

/**
 * item types
 *
 * - author: TCCODER
 * - version: 1.0
 */
enum SegmentItem {
    case text(String)
}

/**
 * Segment controller delegate protocol
 *
 * - author: TCCODER
 * - version: 1.0
 */
protocol SegmentControllerDelegate: class {
    
    /// did select index handler
    ///
    /// - Parameters:
    ///   - segmentController: the segmentController
    ///   - index: the index
    func segmentController(_ segmentController: SegmentController, didSelectItemAtIndex index: Int)
    
    /// should select index handler
    ///
    /// - Parameters:
    ///   - segmentController: the segmentController
    ///   - index: the index
    /// - Returns: should select or not
    func segmentController(_ segmentController: SegmentController, shouldSelectItemAtIndex index: Int) -> Bool
}

/**
 * Segment controller
 *
 * - author: TCCODER
 * - version: 1.0
 */
class SegmentController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    /// delegate
    weak var delegate: SegmentControllerDelegate?
    
    /// segments
    var segments: [SegmentItem] = [] {
        didSet {
            reloadSegments()
        }
    }
    
    /// segments count
    var segmentsCount: Int {
        return segments.count
    }
    
    /// enables animation for automatically selected segments
    var enableAnimationForAutomaticSelection = true
    
    /// selected index
    var selectedSegmentIndex: Int = 0 {
        didSet {
            updateSelectedCell(animated: enableAnimationForAutomaticSelection)
            updateSelectionIndicator(animated: enableAnimationForAutomaticSelection)
        }
    }
    
    /// currently displayed offset
    var displayedSegmentOffset: CGFloat = 0.0 {
        didSet {
            updateSelectionIndicator(animated: false)
        }
    }
    
    /// strict width for items
    var itemWidth: CGFloat?
    
    /// percent of widths for items
    var itemWidthPercents: [CGFloat]?
    
    /// autoset item width to equal parts of self
    var constraintItemsToBounds = false
    
    fileprivate var flowLayout: UICollectionViewFlowLayout {
        get {
            return collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = false
        
        collectionView?.register(UINib(nibName: SegmentTextItemCell.className, bundle: nil), forCellWithReuseIdentifier: SegmentTextItemCell.className)
        collectionView?.addSubview(selectionIndicatorView)
    }
    
    /// layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentInset()
        updateSelectionIndicator()
    }
    
    /// view appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        autoAdjustItemWidth()
    }
    
    
    /// updates content inset
    private func updateContentInset() {
        guard let _ = viewIfLoaded?.window else { return }
        collectionView?.contentInset = UIEdgeInsetsMake(0, 0, selectionIndicatorHeight, 0)
        let itemSize = CGSize(width: itemWidth ?? 100, height: (collectionView?.bounds.height ?? 0) - selectionIndicatorHeight)
        if flowLayout.itemSize != itemSize {
            flowLayout.itemSize = itemSize
            reloadSegments()
        }
    }
    
    // MARK: - Content
    
    /// reloads segments
    func reloadSegments() {
        flowLayout.invalidateLayout()
        collectionView?.reloadData()
        updateSelectedCell()
        updateSelectionIndicator(animated: false)
    }
    
    /// transition handler
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if constraintItemsToBounds {
            autoAdjustItemWidth(to: size)
        }
    }
    
    /// adjust width to cover size (will use screen size if nil)
    func autoAdjustItemWidth(to size: CGSize? = nil) {
        if constraintItemsToBounds {
            let totalWidth = ((size ?? SCREEN_SIZE).width - flowLayout.minimumLineSpacing * CGFloat(segmentsCount-1))
            itemWidth = totalWidth / CGFloat(segmentsCount)
        }
    }
    
    // MARK: - Selection indicator
    
    /// simple view which uses global tint as its background color
    class SelectionIndicatorView: UIView {
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            tintColorDidChange()
        }
        
        override func tintColorDidChange() {
            super.tintColorDidChange()
            backgroundColor = tintColor
        }
        
    }
    
    /// the indicator view
    private let selectionIndicatorView = SelectionIndicatorView()
    
    /// indicator height
    var selectionIndicatorHeight: CGFloat = 2 {
        didSet {
            updateSelectionIndicator()
        }
    }
    
    /// optional inset
    var selectionIndicatorInset: CGFloat = 20
    
    /// calculate indicator view frame
    private func selectionIndicatorFrame(forIndex index: Int) -> CGRect {
        let y = (collectionView?.bounds.height ?? 0) - selectionIndicatorHeight
        let h = selectionIndicatorHeight
        guard let attributes = flowLayout.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) else {
            return CGRect(x: 0, y: y, width: 0, height: h)
        }
        var frame = attributes.frame
        frame.origin.y = y
        frame.size.height = h
        frame = frame.insetBy(dx: selectionIndicatorInset, dy: 0)
        return frame
    }
    
    /// currently animating indicator or not
    private var isAnimatingSelectionIndicator = false 
    
    
    /// updates selection indicator view
    ///
    /// - Parameter animated: animated or not
    private func updateSelectionIndicator(animated: Bool = false) {
        guard let _ = viewIfLoaded?.window,
            selectedSegmentIndex < collectionView?.numberOfItems(inSection: 0) ?? 0 else { return }
        let currentIndex = selectedSegmentIndex
        var frame = selectionIndicatorFrame(forIndex: currentIndex)
        
        if animated {
            isAnimatingSelectionIndicator = true
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0.0,
                           options: [.beginFromCurrentState],
                           animations: { self.selectionIndicatorView.frame = frame },
                           completion: { _ in
                            self.isAnimatingSelectionIndicator = false
            })
            return
        }
        
        if isAnimatingSelectionIndicator {
            return
        }
        
        var nextIndex = currentIndex
        let offset = displayedSegmentOffset - CGFloat(selectedSegmentIndex)
        if offset > 0 {
            nextIndex += 1
        } else if offset < 0 {
            nextIndex -= 1
        }
        nextIndex = min(max(nextIndex, 0), segmentsCount - 1)
        
        if nextIndex != currentIndex {
            let nextFrame = selectionIndicatorFrame(forIndex: nextIndex)
            let progress = abs(offset)
            frame = CGRect(x: frame.origin.x + (nextFrame.origin.x - frame.origin.x) * progress,
                           y: frame.origin.y + (nextFrame.origin.y - frame.origin.y) * progress,
                           width: frame.width + (nextFrame.width - frame.width) * progress,
                           height: frame.height + (nextFrame.height - frame.height) * progress)
        }
        
        selectionIndicatorView.frame = frame
    }
    
    // MARK: - UICollectionView

    /// cell count
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segmentsCount
    }

    /// cell configuration
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let resultCell: UICollectionViewCell
        switch segments[indexPath.row] {
        case let .text(text):
            let cell = collectionView.getCell(indexPath, ofClass: SegmentTextItemCell.self)
            cell.label.text = text
            resultCell = cell
        }
        resultCell.isSelected = indexPath.item == selectedSegmentIndex
        return resultCell
    }
    
    /// cell selection pre-handler
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return delegate?.segmentController(self, shouldSelectItemAtIndex: indexPath.item) ?? true
    }
    
    /// cell selection
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedSegmentIndex != indexPath.item else {
            return
        }
        selectedSegmentIndex = indexPath.item
        delegate?.segmentController(self, didSelectItemAtIndex: indexPath.item)
    }
    
    /// item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let percents = itemWidthPercents,
            percents.count > indexPath.item {
            var size = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            size.width = floor(size.width * percents[indexPath.item])
            return size
        }
        else {
            return (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        }
    }
    
    /// reselects current
    ///
    /// - Parameter animated: animated or not
    private func updateSelectedCell(animated: Bool = true) {
        guard let _ = viewIfLoaded?.window,
            selectedSegmentIndex < collectionView?.numberOfItems(inSection: 0) ?? 0 else { return }
        collectionView?.selectItem(at: IndexPath(item: selectedSegmentIndex, section: 0),
                                   animated: animated,
                                   scrollPosition: .centeredHorizontally)
    }

}
