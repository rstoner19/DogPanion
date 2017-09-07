//
//  HealthViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/18/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation


class HealthViewController: UIViewController, UNUserNotificationCenterDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate, DismissVCDelegate {
    
    var pet: Pet? = nil
    var delegate: DismissVCDelegate? = nil
    lazy var blurEffectView: UIVisualEffectView? = nil
    lazy var popUpView: PopUpViewController? = nil

    @IBOutlet weak var locationAccessButton: UIButton!
    @IBOutlet weak var birthdayButton: UIButton!
    @IBOutlet weak var medicationButton: UIButton!
    @IBOutlet weak var vaccineButton: UIButton!
    
    @IBOutlet weak var breedLabel: UIButton!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var weightLabel: UIButton!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var maxMinTempLabel: UILabel!
    @IBOutlet weak var timeOne: UILabel!
    @IBOutlet weak var timeTwoLabel: UILabel!
    @IBOutlet weak var timeThreeLabel: UILabel!
    @IBOutlet weak var timeFourLabel: UILabel!
    
    
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var breedTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationAuthorization()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func setup() {
        self.petNameLabel.text = pet?.name
        if let breed = pet?.breed {
            if !breed.isEmpty { self.breedLabel.setTitle(breed, for: .normal) }
        }
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        timeOfDay()
        setHealthItems()
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
    
    @IBAction func darkSkyButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://darksky.net/forecast/47.7205,-122.2067/us12/en") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
    
    @IBAction func locationAccessButtonPressed(_ sender: Any) {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
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
    
    // MARK: Location Manager
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            if let coordinate = self.locationManager.location?.coordinate {
                updateWeather(coordinate: coordinate)
            }
        case .denied:
            self.locationAccessButton.isHidden = false
        default:
            self.locationManager.requestWhenInUseAuthorization()
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
    
    func updateWeather(coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            let lat = String(format: "%.4f", coordinate.latitude); let long = String(format: "%.4f", coordinate.longitude)
            API.shared.GET(latitude: lat, longitude: long, time: nil) { (weather) in
                if let weather = weather, let currentWeather = weather.currentWeather {
                    print(Date(timeIntervalSince1970: currentWeather.forecastTime))
                    self.currentWeatherLabel.text = weather.currentWeatherText()
                    self.maxMinTempLabel.text = weather.currentMaxMinTemp()
                    self.currentWeather(weather: currentWeather.icon)
                    
                    // self.animateWind()
                    // Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
                    //   self.animateWind()
                    // })
                    //  self.animateWeatherChange(weatherType: weather.currentWeather!.icon)
                }
            }
        }
    }
    
    func timeOfDay() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        switch hour {
        case 7..<10:
            self.weatherImage.image = UIImage(named: "sunrise")
        case 10..<19:
            self.weatherImage.image = UIImage(named: "clearDay")
        case 19..<21:
            self.weatherImage.image = UIImage(named: "sunset2")
        default:
            self.weatherImage.image = UIImage(named: "night")
        }
    }
    
    func currentWeather(weather: String) {
        switch weather {
        case "clear-day", "clear-night":
            break
        case "rain":
            animateRain()
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (_) in
                self.animatePartlyCloudy()
            }
        case "snow":
            animateSnow()
            Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { (_) in
                self.animateSnow()
            }
        case "sleet":
            self.animateSleet()
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { (_) in
                self.animateSleet()
            })
        case "wind":
            break // TODO: NEED WIND ANIMATION
        case "fog":
            animateFog()
            Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { (_) in
                self.animateFog()
            }
        case "cloudy":
            animateCloud()
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (_) in
                self.animateCloud()
            }
        default:
            animatePartlyCloudy()
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (_) in
                self.animatePartlyCloudy()
            }
        }
    }
    //TODO: Need to Implement
    func animateWeatherChange(weatherType: String) {
        if weatherType == "clear-day" {
            UIView.animate(withDuration: 1.5, animations: {
                self.weatherImage.alpha = 0.2
            }, completion: { (_) in
                self.weatherImage.image = UIImage(named: "cloudyDay")
                UIView.animate(withDuration: 2.0, animations: {
                    self.weatherImage.alpha = 1.0
                })
            })
        }
    }
    
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
        cloudView.alpha = 0.5
        self.view.addSubview(cloudView)
        UIView.animate(withDuration: 30.0 - Double(random), delay: 0, options: .curveLinear, animations: {
            cloudView.transform = CGAffineTransform(translationX: -self.view.frame.maxX - 600, y: 0)
        }) { (_) in
           cloudView.removeFromSuperview()
        }
    }
    
    func animateFog() {
        let fog = UIImage(named: "fog")
        let y = weatherImage.frame.minY + 45
        let frame = CGRect(x: weatherImage.frame.maxX, y: y, width: 600, height: self.weatherImage.frame.height * 1.4)
        let cloudView = UIImageView(image: fog)
        cloudView.frame = frame
        cloudView.alpha = 0.5
        self.view.addSubview(cloudView)
        UIView.animate(withDuration: 40.0, delay: 0, options: .curveLinear, animations: {
            cloudView.transform = CGAffineTransform(translationX: -self.view.frame.maxX - 700, y: 0)
        }) { (_) in
            cloudView.removeFromSuperview()
        }
    }
    
    func animatePartlyCloudy() {
        let cloud = UIImage(named: "partlyCloudy")
        let y = weatherImage.frame.minY + 60 + CGFloat(arc4random_uniform(40))
        let frame = CGRect(x: weatherImage.frame.maxX, y: y, width: 350, height: 110)
        let cloudView = UIImageView(image: cloud)
        cloudView.frame = frame
        cloudView.alpha = 0.5
        self.view.addSubview(cloudView)
        UIView.animate(withDuration: 28.0, delay: 0, options: .curveLinear, animations: {
            cloudView.transform = CGAffineTransform(translationX: -self.view.frame.maxX - 600, y: 0)
        }) { (_) in
            cloudView.removeFromSuperview()
        }
    }
    
    func animateRain() {
        let rain = UIImage(named: "rain")
        let y: CGFloat = -140
        let frame = CGRect(x: weatherImage.frame.minX, y: y, width: self.view.frame.width, height: 140)
        let rainView = UIImageView(image: rain)
        rainView.frame = frame
        self.view.addSubview(rainView)
        UIView.animate(withDuration: 10, delay: 0, options: .curveLinear, animations: {
            rainView.transform = CGAffineTransform(translationX: 0, y: +400)
            rainView.alpha = 0.05
        }) { (_) in
            rainView.removeFromSuperview()
        }
    }
    
    func animateSleet() {
        let sleet = UIImage(named: "sleet")
        let y: CGFloat = -140
        let frame = CGRect(x: weatherImage.frame.minX, y: y, width: self.view.frame.width, height: 140)
        let sleetView = UIImageView(image: sleet)
        sleetView.frame = frame
        self.view.addSubview(sleetView)
        UIView.animate(withDuration: 10.0, delay: 0, options: .curveLinear, animations: {
            sleetView.transform = CGAffineTransform(translationX: 0, y: +400)
            sleetView.alpha = 0.15
        }) { (_) in
            sleetView.removeFromSuperview()
        }
    }
    
    func animateSnow() {
        let snow = UIImage(named: "snow2")
        let y: CGFloat = -140
        let frame = CGRect(x: weatherImage.frame.minX, y: y, width: self.view.frame.width, height: 140)
        let snowView = UIImageView(image: snow)
        snowView.frame = frame
        self.view.addSubview(snowView)
        UIView.animate(withDuration: 30.0, delay: 0, options: .curveLinear, animations: {
            snowView.transform = CGAffineTransform(translationX: 0, y: +400)
            snowView.alpha = 0.05
        }) { (_) in
            snowView.removeFromSuperview()
        }
    }
    
    func animateWind() {
        let wind = UIImage(named: "wind")
        let y = weatherImage.frame.minY + 60 + CGFloat(arc4random_uniform(40))
        let frame = CGRect(x: weatherImage.frame.maxX, y: y, width: 350, height: 110)
        // TODO: need another wind option
        let windView = UIImageView(image: wind)
        windView.frame = frame
        windView.alpha = 0.5
        self.view.addSubview(windView)
        UIView.animate(withDuration: 4.0, delay: 0, options: .curveLinear, animations: {
            windView.transform = CGAffineTransform(translationX: -self.view.frame.maxX - 600, y: 0)
        }) { (_) in
            windView.removeFromSuperview()
        }
    }

}
