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
    
    init(currentWeather: CurrentWeather, currentDay: [CurrentWeather]) {
        self.currentWeather = currentWeather
        self.currentDayWeather = currentDay
    }
    
}
