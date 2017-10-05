//
//  PetLocationsViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/15/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PetLocationsViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, DismissVCDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var groomingButton: UIButton!
    @IBOutlet weak var dogParkButton: UIButton!
    @IBOutlet weak var vetButton: UIButton!
    @IBOutlet weak var petStoreButton: UIButton!
    
    @IBOutlet var dogParkGesture: UILongPressGestureRecognizer!
    @IBOutlet var petStoreGesture: UILongPressGestureRecognizer!
    @IBOutlet var groomingGesture: UILongPressGestureRecognizer!
    @IBOutlet var vetGesture: UILongPressGestureRecognizer!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    let locationManager = CLLocationManager()
    var delegate: DismissVCDelegate? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var pinType: LocationType? = nil
    var searchMapItems: [MKMapItem]? = nil
    var currentLocationItem: MKMapItem? = nil
    var didUpdateLocation: Bool = false
    var optionsView: LocationOptions? = nil
    var blurView: UIVisualEffectView? = nil
    var forceTouchFired = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupSearch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fadeInstructions()
    }
    
    func setup() {
        checkAuthorizationStatus()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.groomingButton.addBorder(color: .black, width: 0.5, radius: nil)
        self.vetButton.addBorder(color: .black, width: 0.5, radius: nil)
        self.dogParkButton.addBorder(color: .black, width: 0.5, radius: nil)
        self.petStoreButton.addBorder(color: .black, width: 0.5, radius: nil)
    }
    
    func setupSearch() {
        searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = searchBar.barTintColor
        let searchBarSize = searchBar.frame.size
        searchController.searchBar.sizeThatFits(searchBarSize)
        definesPresentationContext = true
        searchTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        delegate?.dismissVC()
    }
    
    @IBAction func setSearchButtonPressed(_ sender: UIButton) {
        if !forceTouchFired {
            removeAnnotations()
            removeOptions()
            switch sender {
            case self.dogParkButton:
                pinType = .dogPark
                searchRequest(queryRequest: "dog park")
            case self.groomingButton:
                pinType = .grooming
                searchRequest(queryRequest: "pet groomer")
            case self.vetButton:
                pinType = .vet
                searchRequest(queryRequest: "veterinarians")
            case self.petStoreButton:
                pinType = .petStore
                searchRequest(queryRequest: "Pet Stores")
            default:
                break
            }
        }
    }
    
    @IBAction func forceTouchCheck(_ sender: UIButton, forEvent event: UIEvent) {
        if let force = event.allTouches?.first?.force {
            if force > CGFloat(5)  && self.optionsView == nil && !forceTouchFired{
                self.forceTouchFired = true
                blurButtons()
                removeOptions()
                let pinType = getPinType(button: sender)
                searchOptions(pinType: pinType, button: sender)
                let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
                hapticFeedback.impactOccurred()
            }
        }
    }
    
    @IBAction func dogParkLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began && !forceTouchFired {
            blurButtons()
            removeOptions()
            switch sender {
            case dogParkGesture:
                searchOptions(pinType: .dogPark, button: self.dogParkButton)
            case vetGesture:
                searchOptions(pinType: .vet, button: self.vetButton)
            case petStoreGesture:
                searchOptions(pinType: .petStore, button: self.petStoreButton)
            case groomingGesture:
                searchOptions(pinType: .grooming, button: self.groomingButton)
            default:
                break
            }
        }
    }
    
    func removeAnnotations() {
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
    }
    
    func getPinType(button: UIButton) -> LocationType {
        let locattionType: LocationType
        switch button {
        case self.petStoreButton:
            locattionType = .petStore
        case self.dogParkButton:
            locattionType = .dogPark
        case self.groomingButton:
            locattionType = .grooming
        case self.vetButton:
            locattionType = .vet
        default:
            locattionType = .dogPark
        }
        return locattionType
    }
    
    func getSearchResults(searchText: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        search.start { (response, _) in
            guard let response = response else { return }
            self.searchMapItems = response.mapItems
            self.searchTableView.reloadData()
            if response.mapItems.count == 0 {
                print("no items returned")
            }
        }
    }
    
    func searchOptions(pinType: LocationType, button: UIButton) {
        self.pinType = pinType
        let frame = getFrame(button: button)
        self.optionsView = PetLocations.getOptions(frame: frame, pinType: pinType)
        if let optionsView = self.optionsView {
            optionsView.delegate = self
            self.view.addSubview(optionsView)
            UIView.animate(withDuration: 0.7, animations: {
                optionsView.transform = CGAffineTransform(scaleX: 1, y: 1)
                optionsView.alpha = 1.0
            }, completion: { (_) in
                self.forceTouchFired = false
            })
        }
    }
    
    func blurButtons() {
        let frame = CGRect(x: self.buttonView.frame.minX, y: self.buttonView.frame.minY, width: self.buttonView.frame.width, height: self.buttonView.frame.height)
        let blurEffect = UIBlurEffect(style: .light)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        self.blurView?.frame = frame
        self.view.addSubview(blurView!)
    }
    
    func fadeInstructions() {
        UIView.animate(withDuration: 1.5, delay: 5.0, options: .curveEaseIn, animations: {
            self.instructionLabel.alpha = 0
        }) { (_) in
        }
    }
    
    func getFrame(button: UIButton) -> CGRect {
        let width = button.bounds.width * 0.9
        return CGRect(x: button.frame.midX - width / 2, y: self.buttonView.frame.midY - 50, width: width, height: 100)
    }
    
    func removeOptions() {
        if let _ = self.optionsView {
            self.optionsView?.removeFromSuperview()
            self.blurView?.removeFromSuperview()
            self.optionsView = nil
            self.blurView = nil
        }
    }
    
    // MARK: DismissVC Delegate
    func dismissVC() {
        self.optionsView?.removeFromSuperview()
    }
    
    func dismissVC(object: Any) {
        removeAnnotations()
        if let searchString = object as? String {
            if searchString != "" {
                searchRequest(queryRequest: searchString)
            } else { return }
        }
        removeOptions()
    }
    
    // MARK: MapView
    func searchRequest(queryRequest: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = queryRequest
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, _) in
            guard let response = response else { return }
            for item in response.mapItems {
                self.addPinToMap(mapItem: item)
            }
            if response.mapItems.count == 0 {
                print("no items returned")
            }
        }
    }
    
    func addPinToMap(mapItem: MKMapItem) {
        let location = mapItem.placemark.coordinate
        let annotation = MapAnnotation(cordinate: location, title: mapItem.name)
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) { return nil }
        var reuseID = "pin"
        if let pinType = pinType {
            reuseID = pinType.rawValue
        }
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            if let pinType = pinType {
                pinView?.image = PetLocations.setPinImage(pinType: pinType)
            }
            pinView?.centerOffset = CGPoint(x: 0, y: -25)
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            let image = UIImage(named: "carIcon")
            button.setImage(image, for: .normal)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let selectedLocation = view.annotation
        if currentLocationItem == nil {
            currentLocationItem = MKMapItem.forCurrentLocation()
        }
        let selectedPlaceMark = MKPlacemark(coordinate: (selectedLocation?.coordinate)!)
        let selectMapItem = MKMapItem(placemark: selectedPlaceMark)
        selectMapItem.name = (view.annotation?.title)!
        let mapItems = [currentLocationItem!, selectMapItem]
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault]
        MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
    }
    
    
    // MARK: Location Manager
    func checkAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            self.currentLocationItem = MKMapItem.forCurrentLocation()
            mapView.showsUserLocation = true
            if let location = locationManager.location {
                centerOnLocation(location: location, regionRadius: 6000)
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkAuthorizationStatus()
        }
    }
    
    func centerOnLocation(location: CLLocation, regionRadius: CLLocationDistance) {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: SearchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentLocationItem = searchMapItems?.first
        if let location = currentLocationItem?.placemark.location {
            centerOnLocation(location: location, regionRadius: 6000)
        }
        self.searchController.searchBar.text = ""
        self.searchTableView.isHidden = true
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.text = ""
        self.searchTableView.isHidden = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchTableView.isHidden = false
        self.resignFirstResponder()
        searchController.searchBar.becomeFirstResponder()
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchMapItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        if let items = searchMapItems {
            cell.textLabel?.text = items[indexPath.row].name
            cell.detailTextLabel?.text = items[indexPath.row].placemark.title
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.searchController.searchBar.text = cell?.textLabel?.text
    }
}
