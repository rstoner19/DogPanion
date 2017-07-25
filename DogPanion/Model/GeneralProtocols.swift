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
    func dismissVCAfterDelete()
    func dismissVC(object: Any) //optional
}

extension DismissVCDelegate {
    func dismissVCAfterDelete() {
    }
    func dismissVC(object: Any) {
    }
}

enum LocationType : String {
    case vet;
    case petStore;
    case dogPark;
    case grooming;
}
