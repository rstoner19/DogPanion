//
//  DailyWeather.swift
//  DogPanion
//
//  Created by Rick Stoner on 9/1/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import Foundation

class DailyWeather {
    
    let forecastTime: TimeInterval
    let icon: String
    let precipProbability: Double
    let summary: String
    let maxTemp: Double
    let minTemp: Double
    
    init?(json: [String : AnyObject]) {
        if let minTemp = json["temperatureMin"] as? Double, let maxTemp = json["temperatureMax"] as? Double, let precipProbability = json["precipProbability"] as? Double, let summary = json["summary"] as? String, let icon = json["icon"] as? String, let forecastTime = json["time"] as? TimeInterval {
            self.forecastTime = forecastTime
            self.icon = icon
            self.precipProbability = precipProbability
            self.summary = summary
            self.maxTemp = maxTemp
            self.minTemp = minTemp
        } else { return nil }
    }
    
    func forecastDay() -> String {
        let time = Date(timeIntervalSince1970: self.forecastTime)
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = "EEE"
        return formatter.string(from: time)
    }
}
