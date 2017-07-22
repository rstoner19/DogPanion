//
//  GeneralProtocols.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/11/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import Foundation

protocol DismissVCDelegate : class {
    func dismissVC()
    
}

extension DismissVCDelegate {
    func dismissVC(object: Any) {
        
    }
}

enum PinColor : String {
    case redPin;
    case bluePin;
    case greenPin;
    case purplePin;
}
