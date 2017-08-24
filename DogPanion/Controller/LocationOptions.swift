//
//  LocationOptions.swift
//  DogPanion
//
//  Created by Rick Stoner on 8/23/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class LocationOptions: UIView {
    
    var delegate: DismissVCDelegate? = nil
    
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        delegate?.dismissVC(object: sender.currentTitle ?? "")
    }

}
