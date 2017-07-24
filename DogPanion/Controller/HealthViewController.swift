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
    var notificationStatus: Bool = false
    lazy var blurEffectView: UIVisualEffectView? = nil
    lazy var popUpView: PopUpViewController? = nil

    @IBOutlet weak var birthdayButton: UIButton!
    
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
        
        if let health = pet?.health {
            if let birthday = health.birthday as Date? {
                self.birthdayButton.setTitle(birthday.toString(), for: .normal)
            }
        }
    }
    
    @IBAction func enterBirthdayButtonPressed(_ sender: UIButton) {
        let blurEffect = UIBlurEffect(style: .light
        )
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
    
    // MARK: Dismiss Delegate
    
    func dismissVC() {
        removeBlurView()
    }
    
    func dismissVCtwo(object: Any) {
        removeBlurView()
        if let date = object as? NSDate {
            self.birthdayButton.setTitle((date as Date).toString(), for: .normal)
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
                self.notificationSwitch.isOn = granted
                self.notificationStatus = granted
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, identifier: String, dateToNotify: Date, dateCompenents: DateComponents, repeatNotifcation: Bool) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: repeatNotifcation)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
}
