//
//  AddMedVacViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/26/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class AddMedVacViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, DismissVCDelegate {
    
    var delegate: DismissVCDelegate? = nil
    var pet: Pet? = nil
    var medOrVac: MedVac = .medicine
    var medVacData = MedVacElements()
    lazy var blurEffectView: UIVisualEffectView? = nil
    lazy var popUpView: PopUpViewController? = nil
    
    @IBOutlet weak var dateGivenButton: UIButton!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var frequencyPicker: UIPickerView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        switch medOrVac {
        case .medicine:
            self.nameTextField.placeholder = "Medicine Name"
            self.headerLabel.text = "Add Medicine"
            self.nameLabel.text = "Medicine Name:"
        case.vaccine:
            self.nameTextField.placeholder = "Vaccination Name"
            self.headerLabel.text = "Add Vaccination"
            self.nameLabel.text = "Vaccination Name:"
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissVC()
    }
    
    
    @IBAction func dateGivenPressed(_ sender: UIButton) {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView!)
        popUpView = self.storyboard?.instantiateViewController(withIdentifier: "popUpDatePicker") as? PopUpViewController
        if let viewController = popUpView {
            viewController.delegate = self
            self.addChildViewController(viewController)
            viewController.view.frame = self.view.frame
            self.view.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        if let date = medVacData.date, let name = medVacData.name {
            guard let context = pet?.managedObjectContext else { return }
            switch medOrVac {
            case .medicine:
                let medicine = Medicine(context: context)
                medicine.dateGiven = date as NSDate
                medicine.name = name
                medicine.frequency = frequencyPicker.description
            case .vaccine:
                let vaccine = Vaccines(context: context)
                vaccine.dateGiven = date as NSDate
                vaccine.name = name
                vaccine.frequency = frequencyPicker.description
            }
        } else {
            let message = "Please ensure you include a name and date given."
            self.alert(message: message, title: "Incomplete Information")
        }
    }
    
    // MARK: - DismissVC Delegate
    
    func dismissVC() {
        removeBlurView()
    }
    
    func dismissVC(object: Any) {
        removeBlurView()
        if let date = object as? Date {
            self.dateGivenButton.setTitle(date.toString(), for: .normal)
            medVacData.date = date
        }
    }
        
    func removeBlurView() {
        if let blurView = blurEffectView {
            blurView.removeFromSuperview()
        }
    }
    
    // MARK: - PickerView
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.frequencyElements.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.frequencyElements[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
