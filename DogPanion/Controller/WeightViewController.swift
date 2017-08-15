//
//  WeightViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 8/10/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class WeightViewController: UIViewController {
    
    var delegate: DismissVCDelegate? = nil
    var weights: [Weight]? = nil
    
    @IBOutlet weak var weightLineChart: LineChart!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupGraph()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissVC(object: true)
    }
    
    func setup() {
        let locale = Locale.current
        self.weightLabel.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
        self.weightLabel.text = locale.usesMetricSystem ? "Weight: (kg)" : "Weight: (lbs)"
    }

    func setupGraph() {
        var points: [CGPoint] = []
        if var weights = self.weights {
            if weights.count > 1 {
                print(weights.count)
                Weight.orderWeightByDate(weights: &weights)
                guard let initialDate = weights.first?.dateMeasured! as Date? else { return }
                for weight in weights {
                    let days = (weight.dateMeasured! as Date).timeIntervalSince(initialDate as Date)
                    print(days)
                    let point = CGPoint(x: days, y: weight.weight)
                    points.append(point)
                }
                weightLineChart.deltaX = 20
                weightLineChart.deltaY = 30
                
                weightLineChart.plot(points)
            } else {
                self.alertLabel.isHidden = false
            }
        }
    }
    
}
