//
//  WeightViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 8/10/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class WeightViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: DismissVCDelegate? = nil
    var weights: [Weight]? = nil
    var petName: String? = nil
    var points: [CGPoint] = []
    
    @IBOutlet weak var weightLineChart: LineChart!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    
    @IBOutlet weak var weightTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTableView()
        setupGraph()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissVC(object: true)
    }
    
    func setup() {
        let locale = Locale.current
        self.weightLabel.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
        self.weightLabel.text = locale.usesMetricSystem ? "Weight: (kg)" : "Weight: (lbs)"
        self.nameLabel.text = self.petName
    }
    
    func setupTableView() {
        self.weightTableView.rowHeight = 60
        let nib = UINib(nibName: "WeightCell", bundle: nil)
        self.weightTableView.register(nib, forCellReuseIdentifier: "weightCell")
    }

    func setupGraph() {
        if var weights = self.weights {
            if weights.count > 1 {
                if points.isEmpty { Weight.orderWeightByDate(weights: &weights) }
                points = []
                let units = Weight.getDayRange(weights: weights)
                guard let initialDate = weights.first?.dateMeasured! as Date? else { return }
                for weight in weights {
                    let days = (weight.dateMeasured! as Date).timeIntervalSince(initialDate as Date) / units.divisor
                    let point = CGPoint(x: days, y: weight.weight)
                    points.append(point)
                }
                self.timeLabel.text = units.timePeriod
                weightLineChart.deltaX = CGFloat(ceil(units.timeRange / (units.divisor * 6)))
                weightLineChart.deltaY = 10
                weightLineChart.plot(points)
            } else {
                self.alertLabel.isHidden = false
            }
        }
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weights?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weightCell", for: indexPath) as! WeightCell
        guard let count = weights?.count else { return cell }
        if let weight = weights?[count - 1 - indexPath.row] {
            let measurement = Locale.current.usesMetricSystem ? " kg" : " lbs"
            cell.weight = weight.weight
            cell.dateLabel.text = (weight.dateMeasured! as Date).toString()
            cell.weightLabel.text = String(format:"%.1f", weight.weight) + measurement
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let count = weights?.count else { return }
            guard let weight = weights?.remove(at: (count - 1 - indexPath.row)) else { return }
            guard let context = weight.managedObjectContext else { return }
            context.delete(weight)
            CoreDataManager.shared.saveItem(context: context, saveItem: "Delete weight item")
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            self.weightLineChart.chartTransform = nil
            self.weightLineChart.circlesHighlightLayer.path = nil
            setupGraph()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !points.isEmpty {
            let count = points.count
            self.weightLineChart.circlesHighlightLayer.path = weightLineChart.circles(atPoints: [self.points[count - 1 - indexPath.row]], withTransform: weightLineChart.chartTransform!, circleSize: 12)
        }
    }
    
}
