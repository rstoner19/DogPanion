//
//  PetImages.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/9/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import Foundation
import AVFoundation


class PetImages {
    
    
    func checkAccess () {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch  authStatus {
        case .authorized:
            print("author")
        case .denied:
            print("denied")
        case .notDetermined:
            print("not")
        case .restricted:
            print("restricted")
        }
    }
}
