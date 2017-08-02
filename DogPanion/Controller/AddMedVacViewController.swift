//
//  AddMedVacViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/26/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class AddMedVacViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, DismissVCDelegate {
    
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
    
    @IBOutlet weak var reminderSwitch: UISwitch!
    
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
        setupLabels()
        self.nameTextField.delegate = self
        if let reminders = pet?.health?.notifications {
            if !reminders {
                self.reminderSwitch.isOn = false
                self.reminderSwitch.isEnabled = false
            }
        }
    }
    
    func setupLabels() {
        if medicine != nil {
            self.nameTextField.text = medicine?.name
            if let date = medicine?.dateGiven as Date? {
                self.dateGivenButton.setTitle(date.toString(), for: .normal)
            }
            self.reminderSwitch.isOn = medicine?.reminder ?? false
            if let frequency = medicine?.frequency {
                self.frequencyPicker.selectRow(AddMedVac.pickerComponents(frequency: frequency), inComponent: 0, animated: false)
            }
        } else if vaccine != nil {
            self.nameTextField.text = vaccine?.name
            if let date = vaccine?.dateGiven as Date? {
                self.dateGivenButton.setTitle(date.toString(), for: .normal)
            }
            self.reminderSwitch.isOn = vaccine?.reminder ?? false
            if let frequency = vaccine?.frequency {
                self.frequencyPicker.selectRow(AddMedVac.pickerComponents(frequency: frequency), inComponent: 0, animated: false)
            }
        }
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
    
    var medicine: Medicine? = nil {
        didSet {
            medVacData.name = medicine?.name
            medVacData.date = medicine?.dateGiven as Date?
        }
    }
    
    var vaccine: Vaccines? = nil {
        didSet {
            medVacData.name = vaccine?.name
            medVacData.date = vaccine?.dateGiven as Date?
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissVC()
    }
    
    @IBAction func dateGivenPressed(_ sender: UIButton) {
        self.view.endEditing(true)
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
            let frequencyrow = self.frequencyPicker.selectedRow(inComponent: 0)
            let timeOfDayRow = self.frequencyPicker.selectedRow(inComponent: 1)
            let frequency = Constants.frequencyElements[0][frequencyrow]
            let timeOfDay = Constants.frequencyElements[1][timeOfDayRow]
            let notificationIDs = self.setNotifications(medVacName: name, date: date, frequency: frequency, timeOfDay: timeOfDay)
            if medicine != nil {
                if let notificationToDelete = medicine?.getNotificationsIDs() {
                    NotificationManager.deleteNotication(identifiers: notificationToDelete)
                }
                medicine?.notificationID = nil; medicine?.notificationIDTwo = nil; medicine?.notificationIDThree = nil; medicine?.notificationIDFour = nil
                medicine?.populateMedicine(frequency: frequency, name: name, date: date, timeOfDay: timeOfDay, reminder: self.reminderSwitch.isOn, notificationIDs: notificationIDs)
            } else if vaccine != nil {
                if let notificationToDelete = vaccine?.getNotificationsIDs() {
                    NotificationManager.deleteNotication(identifiers: notificationToDelete)
                }
                vaccine?.notificationID = nil; vaccine?.notificationIDTwo = nil; vaccine?.notificationIDThree = nil; vaccine?.notificationIDFour = nil
                vaccine?.populatVaccines(frequency: frequency, name: name, date: date, timeOfDay: timeOfDay, reminder: self.reminderSwitch.isOn, notificationIDs: notificationIDs)
            } else {
                switch medOrVac {
                case .medicine:
                    let medicine = Medicine(context: context)
                    medicine.populateMedicine(frequency: frequency, name: name, date: date, timeOfDay: timeOfDay, reminder: self.reminderSwitch.isOn, notificationIDs: notificationIDs)
                    pet?.health?.addToMedicine(medicine)
                case .vaccine:
                    let vaccine = Vaccines(context: context)
                    vaccine.populatVaccines(frequency: frequency, name: name, date: date, timeOfDay: timeOfDay, reminder: self.reminderSwitch.isOn, notificationIDs: notificationIDs)
                    pet?.health?.addToVaccines(vaccine)
                }
            }
            do {
                try context.save()
                self.delegate?.dismissVC()
            } catch {
                print("Error saving medicine or vaccine.", error.localizedDescription)
                self.alert(message: "Sorry, there was an error, please try saving again. If problem persist close app and try again.", title: "Error Saving")
            }
        } else {
            let message = "Please ensure you include a name and date given."
            self.alert(message: message, title: "Incomplete Information")
        }
    }
    
    func setNotifications(medVacName: String, date: Date, frequency: String, timeOfDay: String) -> [String]? {
        if pet?.health?.notifications == true && self.reminderSwitch.isOn {
            let dateComponents = NotificationManager.getDateComponents(startDate: date, frequency: frequency, timeofDay: timeOfDay)
            var notificationIDs: [String] = [medVacName]
            if dateComponents.count == 2 {
                notificationIDs.append(medVacName + "two")
            } else if dateComponents.count == 4 {
                notificationIDs.append(medVacName + "two")
                notificationIDs.append(medVacName + "three")
                notificationIDs.append(medVacName + "four")
            }
            
            let title = medVacName + " is due for " + (pet?.name)!
            let body = "A quick reminder to give \((pet?.name)!) his/her \(medVacName)."
            for index in 0..<dateComponents.count {
                NotificationManager.scheduleNotification(title: title, body: body, identifier: notificationIDs[index], dateCompenents: dateComponents[index], repeatNotifcation: true)
            }
            return notificationIDs
        } else { return nil }
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
        return Constants.frequencyElements[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.frequencyElements[component][row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // MARK: - Textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.medVacData.name = textField.text != "" ? textField.text : nil
        return self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.medVacData.name = textField.text != "" ? textField.text : nil
    }
}
