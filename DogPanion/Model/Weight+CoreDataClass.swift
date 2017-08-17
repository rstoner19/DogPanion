//
//  Weight+CoreDataClass.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/21/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//
//

import Foundation
import CoreData


public class Weight: NSManagedObject {
    
    class func orderWeightByDate(weights: inout [Weight]) {
        weights.sort(by: { ($0.dateMeasured)?.compare(($1.dateMeasured! as Date)) == .orderedAscending })
    }
    
    class func getDayRange(weights: [Weight]) -> (timeRange: Double, divisor:
        Double, timePeriod: String) {
            var result: (timeRange: Double, divisor: Double, timePeriod: String) = (timeRange: 0, divisor: 86400, timePeriod: "days")
        if let firstDate = weights.first?.dateMeasured, let lastDate = weights.last?.dateMeasured {
            let time = (lastDate as Date).timeIntervalSince(firstDate as Date) / 86400
            result.timeRange = time * 86400
            switch time {
            case 0..<3:
                result.divisor = 3600
                result.timePeriod = "Hours"
            case 180..<1080:
                result.divisor = 86400 * 30.437
                result.timePeriod = "Months"
            case 1080..<10000:
                result.divisor = 86400 * 365
                result.timePeriod = "Years"
            default:
                result.divisor = 86400
                result.timePeriod = "Days"
            }
        }
        return result
    }
    
}
