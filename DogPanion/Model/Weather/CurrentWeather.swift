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
    let cloudCover: Double
    let precipProbability: Double
    let humdity: Double
    let summary: String
    let icon: String
    let forecastTime: TimeInterval
    
    init?(json: [String : AnyObject]) {
        if let temperature = json["temperature"] as? Double, let precipProbability = json["precipProbability"] as? Double, let humidity = json["humidity"] as? Double, let summary = json["summary"] as? String, let icon = json["icon"] as? String, let forecastTime = json["time"] as? TimeInterval, let cloudCover = json["cloudCover"] as? Double {
            self.temperature = temperature
            self.precipProbability = precipProbability
            self.summary = summary
            self.icon = icon
            self.humdity = humidity
            self.forecastTime = forecastTime
            self.cloudCover = cloudCover
        } else { return nil }
    }
    
    
}
