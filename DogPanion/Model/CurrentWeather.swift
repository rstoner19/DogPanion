//
//  CurrentWeather.swift
//  DogPanion
//
//  Created by Rick Stoner on 8/31/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import Foundation

class CurrentWeather {
    
    let temperature: Double
    let precipProbability: Double
    let summary: String
    let icon: String
    
    init?(json: [String : AnyObject]) {
        if let temperature = json["temperature"] as? Double, let precipProbability = json["precipProbability"] as? Double, let summary = json["summary"] as? String, let icon = json["icon"] as? String {
            self.temperature = temperature
            self.precipProbability = precipProbability
            self.summary = summary
            self.icon = icon
        } else { return nil }
    }
    
}
