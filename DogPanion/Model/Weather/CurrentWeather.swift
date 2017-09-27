//
//  CurrentWeather.swift
//  DogPanion
//
//  Created by Rick Stoner on 8/31/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class CurrentWeather {
    
    let temperature: Double
    let cloudCover: Double
    let precipProbability: Double
    let precipIntensity: Double
    let humdity: Double
    let summary: String
    let icon: String
    let forecastTime: TimeInterval
    let windSpeed: Double
    
    init?(json: [String : AnyObject]) {
        if let temperature = json["temperature"] as? Double, let precipProbability = json["precipProbability"] as? Double, let humidity = json["humidity"] as? Double, let summary = json["summary"] as? String, let icon = json["icon"] as? String, let forecastTime = json["time"] as? TimeInterval, let cloudCover = json["cloudCover"] as? Double, let precipIntensity = json["precipIntensity"] as? Double, let windSpeed = json["windSpeed"] as? Double {
            self.temperature = temperature
            self.precipProbability = precipProbability
            self.summary = summary
            self.icon = icon
            self.humdity = humidity
            self.forecastTime = forecastTime
            self.cloudCover = cloudCover
            self.precipIntensity = precipIntensity
            self.windSpeed = windSpeed
        } else { return nil }
    }
    
    func isCloudyWeather(timeOfDay: String?) -> UIImage? {
        if self.cloudCover > 0.75 {
            if let timeOfDay = timeOfDay {
                let weatherImage = timeOfDay + "Cloudy"
                return UIImage(named: weatherImage)
            }
        }
        return nil
    }
    
    // Create's 'comparble' weather scale to find out best weather times
    func weatherMeasurment() -> Double {
        let temperatureElement = abs(self.temperature - 70.0)/10
        let precipElement = self.precipIntensity * 25.4 * self.precipProbability
        let windElement = self.windSpeed < 30 ? 0.0 : (self.windSpeed - 30)/10
        print("Temp: ", temperatureElement, " Precip: ", precipElement, " Wind: ", windElement) // TODO: Need to delete
        return temperatureElement + precipElement + windElement
    }
    
    
}
