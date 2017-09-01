//
//  HealthViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/18/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit
import UserNotifications

class HealthViewController: UIViewController, UNUserNotificationCenterDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, DismissVCDelegate {
    
    var pet: Pet? = nil
    var delegate: DismissVCDelegate? = nil
    lazy var blurEffectView: UIVisualEffectView? = nil
    lazy var popUpView: PopUpViewController? = nil

    @IBOutlet weak var birthdayButton: UIButton!
    @IBOutlet weak var medicationButton: UIButton!
    @IBOutlet weak var vaccineButton: UIButton!
    
    @IBOutlet weak var breedLabel: UIButton!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var weightLabel: UIButton!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var breedTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationAuthorization()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        animateSnow()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (_) in
            self.animateSnow()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        self.petNameLabel.text = pet?.name
        if let breed = pet?.breed {
            if !breed.isEmpty {
                self.breedLabel.setTitle(breed, for: .normal)
            }
        }
        setHealthItems()
        API.shared.GET(latitude: "47.6062", longitude: "-122.3321", time: nil)
    }
    
    func setHealthItems() {
        if let health = pet?.health {
            if let birthday = health.birthday as Date? {
                self.birthdayButton.setTitle(birthday.toString(), for: .normal)
            }
            if let weight = pet?.health?.weight?.allObjects as? [Weight] {
                if weight.count > 0 {
                    let sortedWeight = weight.sorted(by: {($0.dateMeasured)?.compare(($1.dateMeasured! as Date)) == .orderedDescending })
                    let stringWeight = String(format:"%.1f", (sortedWeight.first?.weight)!)
                    self.weightLabel.setTitle(stringWeight, for: .normal)
                }
            }
            self.notificationSwitch.isOn = health.notifications
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "medVacVC" {
            guard let medVacVC = segue.destination as? MedVacViewController else { return }
            guard let type = sender as? MedVac else { return }
            medVacVC.delegate = self
            medVacVC.medVac = type
            medVacVC.pet = self.pet
        } else if segue.identifier == "weightVC" {
            guard let weightVC = segue.destination as? WeightViewController else {return}
            weightVC.delegate = self
            if var weights = self.pet?.health?.weight?.allObjects as? [Weight] {
                Weight.orderWeightByDate(weights: &weights)
                weightVC.weights = weights
                weightVC.petName = self.pet?.name
            }
        }
    }
    
    // MARK: Button Actions
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissVC()
    }
    
    @IBAction func enterBirthdayButtonPressed(_ sender: UIButton) {
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
            if let birthday = pet?.health?.birthday as Date? {
                viewController.datePicker.date = birthday
            }
        }
    }
    
    @IBAction func breedButtonPressed(_ sender: UIButton) {
        self.breedTextField.becomeFirstResponder()
    }
    
    @IBAction func weightButtonPressed(_ sender: UIButton) {
        self.weightTextField.addBarToKeyboard(message: "Enter Pet Weight", viewController: self, buttons: true)
        self.weightTextField.becomeFirstResponder()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Delete Pet?", message: "Deleting the pet will delete all of its images and data.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            guard let context = self.pet?.managedObjectContext else { return }
            context.delete(self.pet!)
            do {
                try context.save()
                self.delegate?.dismissVCAfterDelete()
            } catch {
                print("Error deleting pet ", error.localizedDescription)
                let message = "Sorry, there was an error deleting the pet information.  Please try to close the app and try again."
                self.alert(message: message, title: "Error")
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func medVacButtonPressed(_ sender: UIButton) {
        let type: MedVac
        if sender == self.medicationButton {
            type = .medicine
        } else {
            type = .vaccine
        }
        self.performSegue(withIdentifier: "medVacVC", sender: type)
    }
    
    @IBAction func notificationSwitchChanged(_ sender: UISwitch) {
        if !sender.isOn {
            alertAboutDeletingNotifcations()
        } else {
            self.pet?.health?.notifications = sender.isOn
            guard let context = pet?.managedObjectContext else { return }
            CoreDataManager.shared.saveItem(context: context, saveItem: "notifications")
            if pet?.health?.birthday != nil {
                guard let birthday = pet?.health?.birthday as Date? else { return }
                birthdayReminder(birthday: birthday)
            }
        }
    }
    
    func alertAboutDeletingNotifcations() {
        let alertController = UIAlertController(title: "Turn off Notifications?", message: "Turning off notifications will remove ALL notifications for this pet. Proceed?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Turn Off", style: .destructive, handler: { (action: UIAlertAction!) in
            self.pet?.health?.notifications = false
            guard let context = self.pet?.managedObjectContext else { return }
            self.deleteNotifications()
            CoreDataManager.shared.saveItem(context: context, saveItem: "Delete notifications")
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.notificationSwitch.isOn = true
            }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteNotifications() {
        if let vaccines = pet?.health?.vaccines?.allObjects as? [Vaccines] {
            for vaccine in vaccines {
                if vaccine.reminder {
                    vaccine.reminder = false
                    NotificationManager.deleteNotication(identifiers: vaccine.getNotificationsIDs())
                }
            }
        }
        if let medicines = pet?.health?.medicine?.allObjects as? [Medicine] {
            for medicine in medicines {
                if medicine.reminder {
                    medicine.reminder = false
                    NotificationManager.deleteNotication(identifiers: medicine.getNotificationsIDs())
                }
            }
        }
    }
    
    // MARK: Dismiss Delegate
    func dismissVC() {
        removeBlurView()
    }
    
    func dismissVC(object: Any) {
        removeBlurView()
        if let date = object as? NSDate {
            self.birthdayButton.setTitle((date as Date).toString(), for: .normal)
            birthdayReminder(birthday: (date as Date))
            pet?.health?.birthday = date
            let context = pet?.managedObjectContext
            do {
                try context?.save()
            } catch {
                print("Error saving birthday ", error.localizedDescription)
            }
        }
        if let _ = object as? Bool {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func removeBlurView() {
        if let blurView = blurEffectView {
            blurView.removeFromSuperview()
        }
    }
    
    // MARK: Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == breedTextField {
            pet?.breed = textField.text
            if let context = pet?.managedObjectContext {
                CoreDataManager.shared.saveItem(context: context, saveItem: "breed")
            }
        }
        return self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.weightTextField {
            if let context = pet?.managedObjectContext {
                let weight = Weight(context: context)
                weight.dateMeasured = Date() as NSDate
                weight.weight = Double(self.weightTextField.text!) ?? 0
                pet?.health?.addToWeight(weight)
                CoreDataManager.shared.saveItem(context: context, saveItem: "weight")
            }
        }
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        if sender == self.breedTextField {
            self.breedLabel.setTitle(sender.text, for: .normal)
        } else if sender == self.weightTextField {
            self.weightLabel.setTitle(sender.text, for: .normal)
        }
    }
    
    //Mark: UserNotification Center
    func notificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (granted, error) in
            DispatchQueue.main.async {
                if !granted {
                    self.pet?.health?.notifications = granted
                    self.notificationSwitch.isOn = granted
                }
                self.notificationSwitch.isEnabled = granted
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, identifier: String, dateCompenents: DateComponents, repeatNotifcation: Bool) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: repeatNotifcation)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
    func birthdayReminder(birthday: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: birthday)
        var date = DateComponents()
        date.hour = 12
        date.day = components.day
        date.month = components.month
        let title = "Happy Birthday to " + (pet?.name ?? "your pet")
        let body = Constants.appName + " wishes " + (pet?.name ?? "your pet") + " a happy birthday! 🐶🎂🎈🎁"
        NotificationManager.scheduleNotification(title: title, body: body, identifier: "\(pet?.name ?? "")birthday", dateCompenents: date, repeatNotifcation: true)
    }
    
    // MARK: Weather
    func animateCloud() {
        let cloud: UIImage?
        let random = arc4random_uniform(3)
        switch random {
        case 0:
            cloud = UIImage(named: "cloud")
        case 1:
            cloud = UIImage(named: "cloudTwo")
        default:
            cloud = UIImage(named: "cloudThree")
        }
        let y = weatherImage.frame.minY + 60 + CGFloat(arc4random_uniform(40))
        let frame = CGRect(x: weatherImage.frame.maxX, y: y, width: 350, height: 110)
        let cloudView = UIImageView(image: cloud)
        cloudView.frame = frame
        self.view.addSubview(cloudView)
        UIView.animate(withDuration: 30.0 - Double(random), delay: 0, options: .curveLinear, animations: {
            cloudView.transform = CGAffineTransform(translationX: -self.view.frame.maxX - 600, y: 0)
        }) { (_) in
           cloudView.removeFromSuperview()
        }
    }
    
    func animateSnow() {
        let snow = UIImage(named: "snow")
        let y: CGFloat = -100
        let frame = CGRect(x: weatherImage.frame.minX, y: y, width: self.view.frame.width, height: 140)
        let snowView = UIImageView(image: snow)
        snowView.frame = frame
        self.view.addSubview(snowView)
        UIView.animate(withDuration: 30.0, delay: 0, options: .curveLinear, animations: {
            snowView.transform = CGAffineTransform(translationX: 0, y: +400)
            snowView.alpha = 0.3
        }) { (_) in
            snowView.removeFromSuperview()
        }
    }

}
