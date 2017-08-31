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
    
    func GET(latitude: String, longitude: String, time: String?) {
        let baseURL = "https://api.darksky.net/forecast/" + Constants.key + "/" + latitude + "," + longitude
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
                        if let currentjson = json["currently"] as? [String : AnyObject] {
                            currentWeather = CurrentWeather(json: currentjson)
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
