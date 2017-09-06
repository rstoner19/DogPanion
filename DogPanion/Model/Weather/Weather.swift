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
    
}
