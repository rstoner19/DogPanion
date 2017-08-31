//
//  API.swift
//  DogPanion
//
//  Created by Rick Stoner on 8/30/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import Foundation

class API {
    
    static let shared = API()
    
    private let session: URLSession
    
    private init() {
        self.session = URLSession(configuration: .default)
    }
    
    func GET(latitude: String, longitude: String, time: String) {
        
    }
}
