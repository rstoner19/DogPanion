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

class PetLocationsViewController: UIViewController, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var groomingButton: UIButton!
    @IBOutlet weak var dogParkButton: UIButton!
    @IBOutlet weak var vetButton: UIButton!
    @IBOutlet weak var petStoreButton: UIButton!
    
    // TODO: Need to implement dismiss delegate
    // TODO: Change pin colors
    // TODO: Make Buttons have graphics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    func setup() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus(checked: false)
        
        func setBorder(button: UIButton) {
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.borderWidth = 1.0
        }
        setBorder(button: self.groomingButton)
        setBorder(button: self.vetButton)
        setBorder(button: self.petStoreButton)
        setBorder(button: self.dogParkButton)
    }
    
    @IBAction func setSearchButtonPressed(_ sender: UIButton) {
        removeAnnotations()
        shadeButtons()
        sender.backgroundColor? = UIColor.clear
        
        switch sender {
        case self.dogParkButton:
            searchRequest(queryRequest: "dog park")
        case self.groomingButton:
            searchRequest(queryRequest: "pet groomer")
        case self.vetButton:
            searchRequest(queryRequest: "veterinarians")
        case self.petStoreButton:
            searchRequest(queryRequest: "pet stores")
        default:
            break
        }
    }
    
    func shadeButtons() {
        self.groomingButton.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.vetButton.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.petStoreButton.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.dogParkButton.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    }
    
    func removeAnnotations() {
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
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
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID ) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.pinTintColor = MKPinAnnotationView.greenPinColor()
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            let image = UIImage(named: "rightArrow") // TODO: Make this a car icon
            button.setImage(image, for: .normal)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let selectedLocation = view.annotation
        let currentLocationItem = MKMapItem.forCurrentLocation()
        
        let selectedPlaceMark = MKPlacemark(coordinate: (selectedLocation?.coordinate)!)
        let selectMapItem = MKMapItem(placemark: selectedPlaceMark)
        selectMapItem.name = (view.annotation?.title)!
        let mapItems = [currentLocationItem, selectMapItem]
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault]
        MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
    }
    
    
    
    
    // MARK: Location Manager
    func checkAuthorizationStatus(checked: Bool) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            if let location = locationManager.location {
                print(location)
                centerOnLocation(location: location, regionRadius: 8000)
            }
        } else {
            if !checked {
                locationManager.requestWhenInUseAuthorization()
                checkAuthorizationStatus(checked: true)
            }
        }
    }
    
    func centerOnLocation(location: CLLocation, regionRadius: CLLocationDistance) {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(region, animated: true)
    }
    
}
