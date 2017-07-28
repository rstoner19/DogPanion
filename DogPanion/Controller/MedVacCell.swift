//
//  MedVacCell.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/26/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class MedVacCell: UITableViewCell {
    
    @IBOutlet weak var reminderStatus: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var givenDateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var vaccine: Vaccines? = nil {
        didSet {
            if let vaccine = vaccine {
                self.nameLabel.text = vaccine.name
                self.givenDateLabel.text = "Given: " + (vaccine.dateGiven! as Date).toString()
                //TODO: Need to modify it it's past due
                self.dueDateLabel.text = "Due: " + (vaccine.dateDue! as Date).toString()
                self.frequencyLabel.text = "Frequency: " + (vaccine.frequency ?? "")
            }
        }
    }
    
    var medicine: Medicine? = nil {
        didSet {
            if let medicine = medicine {
                self.nameLabel.text = medicine.name
                self.givenDateLabel.text = "Given: " + (medicine.dateGiven! as Date).toString()
                //TODO: Need to modify it it's past due
                self.dueDateLabel.text = "Due: " + (medicine.dateDue! as Date).toString()
                self.frequencyLabel.text = "Frequency: " + (medicine.frequency ?? "")
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
