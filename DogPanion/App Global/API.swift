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
    
    func GET(latitude: String, longitude: String, time: String?, completion: @escaping (_ weather: Weather?) -> ()) {
        let baseURL = "https://api.darksky.net/forecast/" + Constants.key + "/" + latitude + "," + longitude + "?exclude=minutely,flags"
        guard let url = URL(string: baseURL) else { return }
        let urlRequest = URLRequest(url: url)
        let task = self.session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print(error)
            }
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String : AnyObject] {
                        let currentWeather: CurrentWeather?
                        var currentDayWeather: [CurrentWeather] = []
                        var dailyWeather: [DailyWeather] = []
                        if let currentjson = json["currently"] as? [String : AnyObject] {
                            currentWeather = CurrentWeather(json: currentjson)
                        } else { return }
                        if let currentDay = json["hourly"] as? [String: AnyObject], let hourly = currentDay["data"] as? [[String: AnyObject]] {
                            
                            for hour in hourly {
                                guard let hourWeather = CurrentWeather(json: hour) else { break }
                                currentDayWeather.append(hourWeather)
                                let time = Date(timeIntervalSince1970: hourWeather.forecastTime)
                                //print(TimeZone.current.secondsFromGMT())
                                //print(time)
                                //print( )
                                
                            }
                        }
                        if let week =  json["daily"] as? [String: AnyObject], let daily = week["data"] as? [[String: AnyObject]]{
                            for day in daily {
                                guard let weather = DailyWeather(json: day) else { break }
                                dailyWeather.append(weather)
                            }
                        }
                        let weather = Weather(currentWeather: currentWeather!, currentDay: currentDayWeather, forecast: dailyWeather)
                        DispatchQueue.main.async {
                            completion(weather)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        return
                    }
                }
                
            }
        }
        task.resume()
    }
    
}
