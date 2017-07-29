//
//  MedVacCell.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/26/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class MedVacCell: UITableViewCell {
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var reminderStatus: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var givenDateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
        
    var vaccine: Vaccines? = nil {
        didSet {
            if let vaccine = vaccine {
                self.nameLabel.text = vaccine.name
                self.givenDateLabel.text = "Given: " + (vaccine.dateGiven! as Date).toString()
                self.dueDateLabel.text = isPastDue(date: vaccine.dateDue! as Date)
                self.frequencyLabel.text = (vaccine.frequency ?? "")
                self.reminderStatus.text = vaccine.reminder ? "On" : "Off"
            }
        }
    }
    
    var medicine: Medicine? = nil {
        didSet {
            if let medicine = medicine {
                self.nameLabel.text = medicine.name
                self.givenDateLabel.text = "Given: " + (medicine.dateGiven! as Date).toString()
                self.dueDateLabel.text = isPastDue(date: medicine.dateDue! as Date)
                self.frequencyLabel.text = (medicine.frequency ?? "")
                self.reminderStatus.text = medicine.reminder ? "On" : "Off"
                
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup() {
        self.completeButton.isHidden = true
        self.completeButton.layer.cornerRadius = 15
        self.completeButton.layer.borderWidth = 1.0
        self.completeButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func isPastDue(date: Date) -> String {
        if date < Date() {
            self.dueLabel.text = "Past Due: "
            self.dueDateLabel.textColor = .red
            self.contentView.backgroundColor = Constants.pastDueColor
            self.completeButton.isHidden = false
        }
        return date.toString()
    }
    
    func saveChange(givenDate: Date, dueDate: Date) {
        if medicine != nil {
            guard let context = medicine?.managedObjectContext else {return}
            medicine?.dateGiven = givenDate as NSDate
            medicine?.dateDue = dueDate as NSDate
            CoreDataManager.shared.saveItem(context: context, saveItem: "medicine dates")
        } else if vaccine != nil {
            guard let context = vaccine?.managedObjectContext else {return}
            vaccine?.dateGiven = givenDate as NSDate
            vaccine?.dateDue = dueDate as NSDate
            CoreDataManager.shared.saveItem(context: context, saveItem: "vaccine dates")
        }
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
        self.completeButton.isHidden = true
        if let stringDate = self.dueDateLabel.text {
            
            guard var date = stringDate.toDate() else { return }
            let dateGiven = date
            self.givenDateLabel.text = self.dueDateLabel.text
            guard let frequency = self.frequencyLabel.text else { return }
            while date < Date() {
                date = AddMedVac.timeToAdd(frequency: frequency, date: date)
            }
            //Update UI to reflect medicine/vaccine given
            self.contentView.backgroundColor = Constants.currentColor
            self.dueLabel.text = "Due: "
            self.dueDateLabel.textColor = Constants.blueDateColor
            let dueDate = date
            self.saveChange(givenDate: dateGiven, dueDate: dueDate)
            self.dueDateLabel.text = date.toString()
        }
    }
}
