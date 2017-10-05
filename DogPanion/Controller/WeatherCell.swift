//
//  WeatherCell.swift
//  DogPanion
//
//  Created by Rick Stoner on 9/10/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class WeatherCell: UICollectionViewCell {

    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var precipLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var dogWalkIcon: UIImageView!
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var clearView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    var weather: DailyWeather? = nil {
        didSet {
            if let weather = weather {
                self.timeLabel.text = weather.forecastDay()
                self.highLabel.text = "H:" + weather.maxTemp.toString() + "°"
                self.lowLabel.text = "L:" + weather.minTemp.toString() + "°"
                self.precipLabel.text = "Precip: " + (weather.precipProbability * 100).toString() + "%"
                self.iconImage.image = weather.weatherIcon()
            }
        }
    }
    
    var highlight: Bool? = nil {
        didSet {
            if highlight == true {
                let dogIcon = UIImage(named: "walkDogIcon")
                let templateImage = dogIcon?.withRenderingMode(.alwaysTemplate)
                self.dogWalkIcon.image = templateImage
                self.dogWalkIcon.tintColor = UIColor.green
                self.clearView.layer.borderColor = UIColor.green.withAlphaComponent(0.7).cgColor
                self.clearView.layer.borderWidth = 1.5
            }
 
        }
    }
    
    func setup() {
        self.clearView.layer.cornerRadius = 4.0
      
    }


}
