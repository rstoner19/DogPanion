//
//  MapAnnotation.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/17/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(cordinate: CLLocationCoordinate2D, title: String?) {
        self.coordinate = cordinate
        self.title = title
    }
    

}
