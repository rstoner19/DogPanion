//
//  WeightCell.swift
//  DogPanion
//
//  Created by Rick Stoner on 8/15/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class WeightCell: UITableViewCell {
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {

    }
    
    var weight: Double? = nil {
        didSet {
            if let weight = weight {
                let frameHeight = self.frame.height * 0.98
                var height = frameHeight * CGFloat(min(weight, 100.0) / 100)
                height = height > 15 ? height : 15
                addImage(height: height)
            }
        }
    }
    
    func addImage(height: CGFloat) {
        // TODO: Need to update image
        let image = UIImage(named: "carIcon")
        let imageView = UIImageView(image: image)
        let x = self.frame.midX - height / 2 - self.frame.midX * 0.4
        imageView.frame = CGRect(x: x, y: 30 - height / 2, width: height, height: height)
        self.addSubview(imageView)
    }
    
}
