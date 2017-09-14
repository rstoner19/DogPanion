//
//  Weather.swift
//  DogPanion
//
//  Created by Rick Stoner on 8/30/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import Foundation


class Weather {
    
    let currentWeather: CurrentWeather?
    let currentDayWeather: [CurrentWeather]?
    let forecast: [DailyWeather]
    
    init(currentWeather: CurrentWeather, currentDay: [CurrentWeather], forecast: [DailyWeather]) {
        self.currentWeather = currentWeather
        self.currentDayWeather = currentDay
        self.forecast = forecast
    }
    
    func currentWeatherText() -> String? {
        if let currentWeather = self.currentWeather {
            return String(format: "%.0f", currentWeather.temperature) + "°, " + currentWeather.summary
        } else { return "Sorry, error retrieving data" }
    }
    
    func currentMaxMinTemp() -> String {
        if let currentDay = self.forecast.first {
            return "High: " + String(format: "%.0f", currentDay.maxTemp) + "°, Low: " + String(format: "%.0f", currentDay.minTemp) + "°"
        } else {
            return "High: - , Low: -"
        }
    }
    
    func idealCurrentTime() -> String {
        if let dayWeather = self.currentDayWeather, let firstTime = dayWeather.first {
            var bestTime = firstTime
            var minValue = firstTime.weatherMeasurment()
            let count = min(16, dayWeather.count)
            for index in 1..<count {
                let currentValue = dayWeather[index].weatherMeasurment()
                if currentValue < minValue {
                    minValue = currentValue
                    bestTime = dayWeather[index]
                }
            }
            let timeString = Date(timeIntervalSince1970: bestTime.forecastTime).getHour() + " " + bestTime.summary
            let temp = " (" + bestTime.temperature.toString() + "°, "
            let precip = "Precip: " + (bestTime.precipProbability * 100).toString() + "% " + bestTime.precipIntensity.toString() + "in/hr, "
            let windString = "Wind: " + bestTime.windSpeed.toString() + "mph)"
            return timeString + temp + precip + windString
        }
        return ""
    }
    
    func idealDays() -> [Int:Bool] {
        var bestDaysIndex: [Int:Bool] = [:]
        var weatherValues: [Double] = []
        var avgValue = 0.0; var minValue = 100.0
        for index in 0..<forecast.count {
            let currentValue = self.forecast[index].weatherMeasurment()
            weatherValues.append(currentValue)
            if currentValue < minValue { minValue = currentValue }
            if currentValue <= 0.5 { bestDaysIndex[index] = true }
        }
        if bestDaysIndex.isEmpty {
            avgValue = avgValue / Double(forecast.count)
            for index in 0..<weatherValues.count {
                if weatherValues[index] < avgValue && weatherValues[index] < minValue * 2 {
                    bestDaysIndex[index] = true
                }
            }
            
        }
        return bestDaysIndex
    }
    
}
