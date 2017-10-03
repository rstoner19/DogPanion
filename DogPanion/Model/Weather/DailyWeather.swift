//
//  DailyWeather.swift
//  DogPanion
//
//  Created by Rick Stoner on 9/1/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import Foundation
import UIKit

class DailyWeather {
    
    let forecastTime: TimeInterval
    let icon: String
    let precipProbability: Double
    let precipIntensity: Double
    let precipMaxIntensity: Double
    let summary: String
    let maxTemp: Double
    let minTemp: Double
    let windSpeed: Double
    
    init?(json: [String : AnyObject]) {
        if let minTemp = json["temperatureMin"] as? Double, let maxTemp = json["temperatureMax"] as? Double, let precipProbability = json["precipProbability"] as? Double, let summary = json["summary"] as? String, let icon = json["icon"] as? String, let forecastTime = json["time"] as? TimeInterval, let precipIntensity = json["precipIntensity"] as? Double, let precipMaxIntensity = json["precipIntensityMax"] as? Double, let windSpeed = json["windSpeed"] as? Double {
            self.forecastTime = forecastTime
            self.icon = icon
            self.precipProbability = precipProbability
            self.summary = summary
            self.maxTemp = maxTemp
            self.minTemp = minTemp
            self.precipIntensity = precipIntensity
            self.precipMaxIntensity = precipMaxIntensity
            self.windSpeed = windSpeed
        } else { return nil }
    }
    
    func forecastDay() -> String {
        let time = Date(timeIntervalSince1970: self.forecastTime)
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = "EEE"
        return formatter.string(from: time)
    }
    
    func weatherIcon() -> UIImage? {
        let imageName: String
        switch self.icon {
        case "clear-day", "clear-night":
            imageName = "clearIcon"
        case "rain":
            imageName = "rainIcon"
        case "snow":
            imageName = "snowIcon"
        case "sleet":
            imageName = "sleetIcon"
        case "wind":
            imageName = "windIcon"
        case "partly-cloudy-day":
            imageName = "partlyCloudyIcon"
        case "partly-cloudy-night":
            imageName = "partlyCloudNightIcon"
        default:
            imageName = "cloudyIcon"
        }
        return UIImage(named: imageName)
    }
    
    func weatherMeasurment() -> Double {
        let temperatureElement: Double
        if self.maxTemp >= 70 && self.minTemp <= 70 {
            temperatureElement = 0.0
        } else {
            if self.minTemp > 70 {
                temperatureElement = (self.minTemp - 70)/10
            } else {
                temperatureElement = (70 - maxTemp)/10
            }
        }
        let precipElement = self.precipIntensity * 25.4 * self.precipProbability * 7.5
        let windElement = self.windSpeed < 30 ? 0.0 : (self.windSpeed - 30)/10
        return temperatureElement + precipElement + windElement
    }
}
