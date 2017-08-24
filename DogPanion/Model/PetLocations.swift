//
//  PetLocations.swift
//  DogPanion
//
//  Created by Rick Stoner on 8/24/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class PetLocations {
    
    class func setPinImage(pinType: LocationType) -> UIImage {
        let image: UIImage
        switch pinType {
        case .petStore:
            image = UIImage(named: "storePin")!
        case .dogPark:
            image = UIImage(named: "parkPin")!
        case .grooming:
            image = UIImage(named: "groomingPin")!
        case .vet:
            image = UIImage(named: "vetPin")!
        }
        return image
    }
    
    class func getOptions(frame: CGRect) -> LocationOptions? {
        guard let optionView = UINib(nibName: "LocationOptions", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LocationOptions else { return nil }
        optionView.frame = frame
        optionView.alpha = 0.1
        optionView.layer.cornerRadius = 5.0
        optionView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        optionView.firstButton.setTitle("Parks", for: .normal)
        optionView.secondButton.setTitle("Hiking Nearby", for: .normal)
        optionView.thirdButton.setTitle("Lakes", for: .normal)
        
        return optionView
    }
    
}
