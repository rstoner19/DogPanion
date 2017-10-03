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

class HealthViewController: UIViewController, UNUserNotificationCenterDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, DismissVCDelegate, WeatherAnimations {
    
    var pet: Pet? = nil
    var delegate: DismissVCDelegate? = nil
    var dayTime: String? = nil
    lazy var blurEffectView: UIVisualEffectView? = nil
    lazy var popUpView: PopUpViewController? = nil

    @IBOutlet weak var locationAccessButton: UIButton!
    @IBOutlet weak var birthdayButton: UIButton!
    @IBOutlet weak var medicationButton: UIButton!
    @IBOutlet weak var vaccineButton: UIButton!
    
    @IBOutlet weak var breedLabel: UIButton!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var weightLabel: UIButton!
    
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var idealTimeLabel: UILabel!
    @IBOutlet weak var maxMinTempLabel: UILabel!
    @IBOutlet weak var precipChanceLabel: UILabel!
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var breedTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    let locationManager = CLLocationManager()
    var bestDayToWalk: [Int:Bool]? = nil
    
    var weatherForecast = [DailyWeather]() {
        didSet {
            self.weatherCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationAuthorization()
        setup()
        setupCollectionView()
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
        self.dayTime = timeOfDay()
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
                NotificationManager.birthdayReminder(birthday: birthday, petName: pet?.name)
            }
        }
    }
    
    func alertAboutDeletingNotifcations() {
        let alertController = UIAlertController(title: "Turn off Notifications?", message: "Turning off notifications will remove ALL notifications for this pet. Proceed?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Turn Off", style: .destructive, handler: { (action: UIAlertAction!) in
            self.pet?.health?.notifications = false
            guard let context = self.pet?.managedObjectContext else { return }
            self.pet?.health?.deleteNotifications()
            CoreDataManager.shared.saveItem(context: context, saveItem: "Delete notifications")
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.notificationSwitch.isOn = true
            }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Dismiss Delegate
    func dismissVC() {
        removeBlurView()
    }
    
    func dismissVC(object: Any) {
        removeBlurView()
        if let date = object as? NSDate {
            self.birthdayButton.setTitle((date as Date).toString(), for: .normal)
            NotificationManager.birthdayReminder(birthday: (date as Date), petName: pet?.name)
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
    
    // MARK: Collection View
    func setupCollectionView() {
        self.weatherCollectionView.layer.backgroundColor = UIColor.clear.cgColor
        let nib = UINib(nibName: "WeatherCell", bundle: nil)
        self.weatherCollectionView.register(nib, forCellWithReuseIdentifier: "weatherCell")
        let cellLayout = setLayout(width: 80, height: 110, spacing: 10)

        self.weatherCollectionView.collectionViewLayout = cellLayout
    }
    
    func setLayout(width: CGFloat, height: CGFloat, spacing: CGFloat) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = 0
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.weatherForecast.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as! WeatherCell
        cell.weather = self.weatherForecast[indexPath.row]
        if let bestDays = bestDayToWalk {
            let highlight = bestDays[indexPath.row] ?? false
            cell.highlight = highlight
        }
        return cell
     
    }
    
    // MARK: Weather
    func updateWeather(coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            let lat = String(format: "%.4f", coordinate.latitude); let long = String(format: "%.4f", coordinate.longitude)
            print(lat, long)
            API.shared.GET(latitude: lat, longitude: long, time: nil) { (weather) in
                
                if let weather = weather, let currentWeather = weather.currentWeather {
                    if let backgroundImage = currentWeather.isCloudyWeather(timeOfDay: self.dayTime) {
                        self.animateWeatherChange(backgroundImage: backgroundImage)
                    }
                    self.currentWeatherLabel.text = weather.currentWeatherText()
                    self.maxMinTempLabel.text = weather.currentMaxMinTemp()
                    self.currentWeather(weather: currentWeather.icon)
                    self.bestDayToWalk = weather.idealDays()
                    self.weatherForecast = weather.forecast
                    self.precipChanceLabel.text = (currentWeather.precipProbability * 100).toString() + "%"
                    self.idealTimeLabel.text = weather.idealCurrentTime()
                    print("Cloudcover: ", currentWeather.cloudCover)
                } else {
                    self.idealTimeLabel.text = "Error getting information, please try again later"
                }
            }
        }
    }
    
    func timeOfDay() -> String {
        let hour = Date().getHourComponent()
        let timeOfDay: String
        switch hour {
        case 7..<10:
            timeOfDay = "sunrise"
        case 10..<18:
            timeOfDay = "clearDay"
        case 18..<21:
            timeOfDay = "sunset"
        default:
            timeOfDay = "night"
        }
        self.weatherImage.image = UIImage(named: timeOfDay)
        return timeOfDay
    }
    
    func currentWeather(weather: String) {
        switch weather {
        case "clear-day", "clear-night":
            break
        case "rain":
            self.animateRain()
            Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { (_) in
                self.animateRain()
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
            self.animateWind()
            Timer.scheduledTimer(withTimeInterval: 1.25, repeats: true, block: { (_) in
                self.animateWind()
            })
        case "fog":
            animateFog()
            Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { (_) in
                self.animateFog()
            }
        case "cloudy":
            animateCloud()
            Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { (_) in
                self.animateCloud()
            }
        default:
            animatePartlyCloudy()
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (_) in
                self.animatePartlyCloudy()
            }
        }
    }
    
    func animateWeatherChange(backgroundImage: UIImage) {
        UIView.animate(withDuration: 1.0, animations: {
            self.weatherImage.alpha = 0.25
        }, completion: { (_) in
            self.weatherImage.image = backgroundImage
            UIView.animate(withDuration: 1.5, animations: {
                self.weatherImage.alpha = 1.0
            })
        })
    }

}
