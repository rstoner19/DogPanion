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

class PetLocationsViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var groomingButton: UIButton!
    @IBOutlet weak var dogParkButton: UIButton!
    @IBOutlet weak var vetButton: UIButton!
    @IBOutlet weak var petStoreButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    let locationManager = CLLocationManager()
    var delegate: DismissVCDelegate? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var pinColor: PinColor? = nil
    var searchMapItems: [MKMapItem]? = nil
    var currentLocationItem: MKMapItem? = nil
    var didUpdateLocation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupSearch()
    }

    func setup() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus()
        self.groomingButton.addBorder(color: .black, width: 0.5, radius: nil)
        self.vetButton.addBorder(color: .black, width: 0.5, radius: nil)
        self.dogParkButton.addBorder(color: .black, width: 0.5, radius: nil)
        self.petStoreButton.addBorder(color: .black, width: 0.5, radius: nil)
        searchBar.delegate = self
    }
    
    func setupSearch() {
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
        removeAnnotations()
        switch sender {
        case self.dogParkButton:
            pinColor = .greenPin
            searchRequest(queryRequest: "dog park")
        case self.groomingButton:
            pinColor = .purplePin
            searchRequest(queryRequest: "pet groomer")
        case self.vetButton:
            pinColor = .redPin
            searchRequest(queryRequest: "veterinarians")
        case self.petStoreButton:
            pinColor = .bluePin
            searchRequest(queryRequest: "Pet Stores")
        default:
            break
        }
    }
    
    func removeAnnotations() {
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
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
        if let pinColor = pinColor {
            reuseID = pinColor.rawValue
        }
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID ) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            if let pinColor = pinColor {
                pinView?.pinTintColor = setPinColor(pinColor: pinColor)
            }
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
    
    func setPinColor(pinColor: PinColor) -> UIColor {
        let color: UIColor
        switch pinColor {
        case .bluePin:
            color = UIColor.blue
        case .greenPin:
            color = MKPinAnnotationView.greenPinColor()
        case .purplePin:
            color = MKPinAnnotationView.purplePinColor()
        case .redPin:
            color = MKPinAnnotationView.redPinColor()
        }
        return color
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
        locationManager.startUpdatingLocation()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.currentLocationItem = MKMapItem.forCurrentLocation()
            mapView.showsUserLocation = true
            if let location = locationManager.location {
                centerOnLocation(location: location, regionRadius: 6000)
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
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
