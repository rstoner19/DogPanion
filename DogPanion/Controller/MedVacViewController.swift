//
//  MedVacViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/25/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class MedVacViewController: UIViewController {
    
    @IBOutlet weak var petNameLabel: UILabel!
    
    
    var pet: Pet? = nil
    var delegate: DismissVCDelegate? = nil
    var medVac: MedVac = .vaccine

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        switch medVac {
        case .medicine:
            self.petNameLabel.text = (self.pet?.name ?? "Pet") + "'s Medicines"
        case .vaccine:
            self.petNameLabel.text = (self.pet?.name ?? "Pet") + "'s Vaccines"
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissVC(object: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
