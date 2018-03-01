//
//  StoryMapViewController.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/1/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import MapKit
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm

/// option: true - will request for location services on map (if not allowed), false - will never ask after "PreStory*" screens
let OPTION_REQUEST_LOCATION_SERVICES_ON_MAP = false

/**
 * Story map screen
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - API integration
 */
class StoryMapViewController: UIViewController {

    /// the number of items to load
    let LIMIT = 100

    /// the edge insets used to point to the target region
    let MAP_EDGE_INSETS: UIEdgeInsets = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)

    /// the distance in miles used as a threshold to reload data
    let DISTANCE_CHANGE_TO_RELOAD: CLLocationDistance = 0.2

    /// the area around current location to show if no data at all
    let CURRENT_LOCATION_AREA: Double = 20000 // in meters
    let SINGLE_STORY_LOCATION_AREA: Double = 100000 // in meters

    /// outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var storyView: StoryView!
    @IBOutlet weak var countLabel: UILabel!
    
    /// search query
    var query = Variable<String>("")
    /// viewmodel
    var vm = Variable<[Story]>([])
    /// selected
    private var selected: Story?

    /// flag: is currently loading
    internal var isLoading = false

    /// the filter
    var filter: StoryFilter?
    /// the sorting type
    var sorting: StorySortingType = .nearest

    /// the user's current location
    private var currentLocation: CLLocationCoordinate2D?

    /// flag: true - will point map to loaded stories, false - else
    private var needToPointToStories = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVM()
        if OPTION_REQUEST_LOCATION_SERVICES_ON_MAP {
            LocationManager.shared.allowedByUser = true
            LocationManager.shared.startUpdatingLocation()
            LocationManager.shared.stopUpdatingLocation()
        }
        setLocationFilter(mapView.userLocation.coordinate, reload: false)
        query.asObservable()
            .subscribe(onNext: { [weak self] value in
                if let _ = self?.filter {
                    self?.filter?.title = value
                }
                else {
                    self?.filter = StoryFilter(title: value, racetrackIds: [], tagIds: [], location: nil)
                }
                self?.loadData()
            }).disposed(by: rx.bag)
    }

    /// Start monitoring location changes
    ///
    /// - Parameter animated: the animation flag
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let coordinate = LocationManager.shared.locations?.first?.coordinate {
            currentLocation = coordinate
            setLocationFilter(coordinate)
        }
    }

    /// Set racetracks filter
    ///
    /// - Parameter racetracks: the racetracks
    func setRacetrackFilter(_ racetracks: [Racetrack]?) {
        let ids = racetracks == nil ? [] : racetracks!.map({"\($0.id)"})
        if let _ = self.filter {
            self.filter?.racetrackIds = ids
        }
        else {
            self.filter = StoryFilter(title: self.query.value, racetrackIds: ids, tagIds: [], location: nil)
        }
        self.loadData()
    }

    /// Set location filter
    ///
    /// - Parameters:
    ///   - racetrace: the racetrace
    ///   - reload: true - need to reload data
    func setLocationFilter(_ location: CLLocationCoordinate2D, reload: Bool = true) {
        if let _ = self.filter {
            self.filter?.location = (lat: location.latitude, lng: location.longitude)
        }
        else {
            self.filter = StoryFilter(title: self.query.value, racetrackIds: [], tagIds: [], location: (lat: location.latitude, lng: location.longitude))
        }
        if reload {
            self.loadData(isLocationChange: true)
        }
    }

    /// Update sorting
    ///
    /// - Parameter sort: the sorting
    func setSorting(_ sort: StorySortingType) {
        self.sorting = sort
        self.loadData()
    }

    /// Load data
    ///
    /// - Parameter initialLoading: true - if initial loading, false - else
    ///   - initialLocationChange: true - will position map to show given stories, false - else
    internal func loadData(initialLoading: Bool = false, isLocationChange: Bool = false) {
        isLoading = true
        let loadingView = LoadingView.lastLoadingView == nil ? LoadingView(parentView: self.view).show() : nil
        let callback: ([Story], Any)->() = { list, _ in
            self.needToPointToStories = !isLocationChange
            self.vm.value = list
            self.isLoading = false
            loadingView?.terminate()
        }
        let failure: FailureCallback = { (errorMessage) -> () in
            self.showAlert(NSLocalizedString("Error", comment: "Error"), errorMessage)
            self.isLoading = false
            loadingView?.terminate()
        }
        if let filter = filter {
            RestServiceApi.shared.searchStories(filter: filter, sorting: sorting, offset: nil, limit: LIMIT, callback: callback, failure: failure)
        }
        else {
            RestServiceApi.shared.searchStories(sorting: sorting, offset: nil, limit: LIMIT, callback: callback, failure: failure)
        }
    }
    
    /// configure vm
    ///
    /// - Parameter filter: current filter
    private func setupVM() {
        Story.fetch()
            .bind(to: vm)
            .disposed(by: rx.bag)
        vm.asObservable()
            .subscribe(onNext: { [weak self] value in
                self?.mapView.removeAnnotations(self?.mapView.annotations ?? [])
                let annotations = value.map { StoryAnnotation(story: $0) }
                self?.mapView.addAnnotations(annotations)
                if let selected = self?.selected, let annotation = annotations.filter({$0.story.id == selected.id}).first {
                    self?.mapView.selectAnnotation(annotation, animated: false)
                }
                if self?.needToPointToStories ?? false {
                    self?.pointMap(to: value)
                }

                self?.countLabel.text = "Displaying \(value.count) of \(value.count) stories in these area"
            }).disposed(by: rx.bag)
    }

    /// Move map to show the stories
    ///
    /// - Parameter stories: the stories
    private func pointMap(to stories: [Story]) {
        var points = [MKMapPoint]()
        for item in stories {
            let point = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: item.lat, longitude: item.long))
            points.append(point)
        }
        // If no stories, then show current location !
        if let location = currentLocation, points.isEmpty {
            let region = MKCoordinateRegionMakeWithDistance(location, CURRENT_LOCATION_AREA, CURRENT_LOCATION_AREA)
            self.mapView.setRegion(region, animated: true)
        }
        else {
            // If only one story, then show wide area
            if points.count == 1 {
                let region = MKCoordinateRegionMakeWithDistance(MKCoordinateForMapPoint(points.first!), SINGLE_STORY_LOCATION_AREA, SINGLE_STORY_LOCATION_AREA)
                self.mapView.setRegion(region, animated: true)
            }
            else {
                let rects = points.map { MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0)) }
                let fittingRect = rects.reduce(MKMapRectNull, MKMapRectUnion)

                self.mapView.setVisibleMapRect(fittingRect,
                                                edgePadding: self.MAP_EDGE_INSETS,
                                                animated: false)
            }
        }
    }

    /// story tile tap handler
    ///
    /// - Parameter sender: the button
    @IBAction func storyTapped(_ sender: Any) {
        guard let vc = create(viewController: StoryDetailsViewController.self, storyboard: .details) else { return }
        vc.story = selected
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// configure story view
    ///
    /// - Parameter value: selected story
    fileprivate func configureSelected(value: Story) {
        selected = value
        storyView.storyImage.load(url: value.smallImageURL)
        storyView.titleLabel.text = value.title
        storyView.racetrackLabel.text = value.subtitle
        storyView.shortDescriptionLabel.text = value.getDescription()
        storyView.shortDescriptionLabel.setLineHeight(16)
        storyView.chaptersLabel.text = "\(value.chapters.count) \("chapters".localized)"
        storyView.cardsLabel.text = "\(value.cards.count) \("cards".localized)"
        if let currentLocation = currentLocation {
            let distance = Int(currentLocation.distance(to: CLLocationCoordinate2D(latitude: value.lat, longitude: value.long)))
            storyView.milesLabel.text = "\(distance) \("miles".localized)"
        }
        else {
            storyView.milesLabel.text = "N/A \("miles".localized)"
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension StoryMapViewController: MKMapViewDelegate {
    
    /// reuse identifier
    static let kAnnotationView = "kAnnotationView"
    
    /// configure annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? StoryAnnotation else { return nil }
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: StoryMapViewController.kAnnotationView) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: StoryMapViewController.kAnnotationView)
        view.image = mapView.selectedAnnotations.contains { $0.coordinate.longitude == annotation.coordinate.longitude
                                                            && $0.coordinate.latitude == annotation.coordinate.latitude } ? #imageLiteral(resourceName: "mapPinSelected") : #imageLiteral(resourceName: "mapPin")
        return view
    }
    
    /// selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? StoryAnnotation else { return }
        view.image = #imageLiteral(resourceName: "mapPinSelected")
        let old = mapView.selectedAnnotations.filter { $0.coordinate.longitude != annotation.coordinate.longitude
                                                        || $0.coordinate.latitude != annotation.coordinate.latitude }
        
        for a in old {
            mapView.deselectAnnotation(a, animated: false)
        }
        configureSelected(value: annotation.story)
        storyView.isHidden = false
    }
    
    /// deselected
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.image = #imageLiteral(resourceName: "mapPin")
        storyView.isHidden = mapView.selectedAnnotations.isEmpty
    }

    /// Update distance to current location
    ///
    /// - Parameters:
    ///   - mapView: the mapView
    ///   - userLocation: the user location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let coord = userLocation.location?.coordinate {
            let oldCoord = self.currentLocation
            self.currentLocation = coord
            if oldCoord == nil || oldCoord!.distance(to: coord) > DISTANCE_CHANGE_TO_RELOAD {
                setLocationFilter(coord)
            }
        }
    }
    
}

/**
 * story annotation
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryAnnotation: NSObject, MKAnnotation {
    
    /// fields
    var coordinate: CLLocationCoordinate2D
    var story: Story
    
    /// initializer
    init(story: Story) {
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(story.lat), longitude: CLLocationDegrees(story.long))
        self.story = story
    }
    
}

/**
 * Story view
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryView: UIView {
    
    /// fields
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var racetrackLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var chaptersLabel: UILabel!
    @IBOutlet weak var cardsLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
}
