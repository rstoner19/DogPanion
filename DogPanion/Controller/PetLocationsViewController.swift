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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setup() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus(checked: false)
    }
    
    @IBAction func dogParkButtonPressed(_ sender: UIButton) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "dog park"
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
    
    // MARK: MapView
    
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
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    
    // MARK: Location Manager
    func checkAuthorizationStatus(checked: Bool) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            if let location = locationManager.location {
                print(location)
                centerOnLocation(location: location, regionRadius: 16090)
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
