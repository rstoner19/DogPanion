//
//  HealthViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/18/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit
import UserNotifications

class HealthViewController: UIViewController, UNUserNotificationCenterDelegate, UIPopoverPresentationControllerDelegate, DismissVCDelegate {
    
    var pet: Pet? = nil
    var delegate: DismissVCDelegate? = nil
    lazy var blurEffectView: UIVisualEffectView? = nil
    lazy var popUpView: PopUpViewController? = nil

    @IBOutlet weak var birthdayButton: UIButton!
    
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationAuthorization()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        self.petNameLabel.text = pet?.name
        if let health = pet?.health {
            if let birthday = health.birthday as Date? {
                self.birthdayButton.setTitle(birthday.toString(), for: .normal)
            }
            self.notificationSwitch.isOn = health.notifications
        }
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
            if let birthday = pet?.health?.birthday as Date? { viewController.datePicker.date = birthday }
            self.addChildViewController(viewController)
            viewController.view.frame = self.view.frame
            self.view.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissVC()
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
    // TODO: Need to add alert telling user all notifcations will be deleted if turned off
    // TODO: Need to have method to delete all notification when turned off
    // TODO: Need to create notification when turned on/alert user to turn back on for medicine/vaccine
    @IBAction func notificationSwitchChanged(_ sender: UISwitch) {
        self.pet?.health?.notifications = sender.isOn
        guard let context = pet?.managedObjectContext else { return }
        CoreDataManager.shared.saveItem(context: context, saveItem: "notifications")
        if sender.isOn && pet?.health?.birthday != nil {
            guard let birthday = pet?.health?.birthday as Date? else { return }
            birthdayReminder(birthday: birthday)
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
    }
    
    func removeBlurView() {
        if let blurView = blurEffectView {
            blurView.removeFromSuperview()
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
        scheduleNotification(title: title, body: body, identifier: "birthday", dateCompenents: date, repeatNotifcation: true)
    }
    //TODO: Need to delete at some point
    func test() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            for request in requests {
                print(request.identifier)
            }
        }
    }
    
}
