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

class PetLocationsViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
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
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func dogParkButtonPressed(_ sender: UIButton) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "dog park"
        
    }
    
}
