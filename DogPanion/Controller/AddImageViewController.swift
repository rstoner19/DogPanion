//
//  AddImageViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/8/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit
import AVFoundation

class AddImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    weak var delegate: DismissVCDelegate? = nil
    lazy var imagePicker = UIImagePickerController()
    var petInfo: Pet? = nil
    var selectedIndex: Int? = nil
    
    @IBOutlet weak var petNameLabel: UILabel!
    
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveTextButton: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var displayImage: UIImageView!
    
    @IBOutlet weak var displayImageView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        isAvailable()
        self.displayImageView.layer.borderColor = UIColor.black.cgColor
        self.displayImageView.layer.borderWidth = 0.5
        self.petNameLabel.text = petInfo?.name
        self.displayImage.layer.borderWidth = 1
        if let images = petInfo?.images {
            petImages = PetImages.orderImagesByDate(images: images)
        }
    }
    
    func isAvailable() {
        photoLibraryButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary) ? true : false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera) ? true : false
    }
    
    var petImages: [PetImages] = [] {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    
    // MARK: - Navigation
    
    func presentImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        self.imagePicker.allowsEditing = true
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = sourceType
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func checkAccess() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch  authStatus {
        case .authorized:
            presentImagePicker(.camera)
        case .denied:
            self.alert(message: "Access to Camera Denied. To allow access go to Setting > " + Constants.appName + " allow access to camera.", title: "Access Denied")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (_) in
                DispatchQueue.main.async {
                    self.checkAccess()
                }
            })
        case .restricted:
            self.alert(message: "Access to Camera is Restricted", title: "Restricted")
        }
    }
    
    @IBAction func photoLibraryButtonPressed(_ sender: UIButton) {
        presentImagePicker(.photoLibrary)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        checkAccess()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissVC()
    }
    
    // MARK: UICollectionView
    func setupCollectionView() {
        imageCollectionView.collectionViewLayout = ImageCustomFlowLayout(columns: 5, space: 2)
        imageCollectionView.layer.borderColor = UIColor.black.cgColor
        imageCollectionView.layer.borderWidth = 0.5
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petInfo?.images?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "petImagesCell", for: indexPath) as! PetImageCell
        let value = petImages[indexPath.row].image as Data
        guard let image = UIImage.init(data: value) else { return cell }
        cell.petImage.image = image
        cell.petImage.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.saveButton.isEnabled = false
        self.saveTextButton.isEnabled = false
        self.selectedIndex = indexPath.row
        guard let cell = collectionView.cellForItem(at: indexPath) as? PetImageCell else {return}
        self.displayImage.image = cell.petImage.image
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.saveButton.isEnabled = true
        self.saveTextButton.isEnabled = true
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        self.displayImage.image = selectedImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonSelected(_ sender: UIButton) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        guard let context = self.petInfo?.managedObjectContext else { return }
        if let image = self.displayImage.image {
            let images = PetImages(context: context)
            images.date = Date() as NSDate
            guard let imageData = UIImageJPEGRepresentation(image
                , 1.0) as NSData? else {return}
            images.image = imageData
            if let pet = self.petInfo {
                pet.addToImages(images)
                do {
                    try context.save()
                    self.activityIndicator.stopAnimating()
                } catch {
                    self.alert(message: "Error Saving", title: "Sorry, there was an error saving the image, please tray again.")
                    self.activityIndicator.stopAnimating()
                }
            }
            self.petImages.append(images)
            self.saveButton.isEnabled = false
            self.saveTextButton.isEnabled = false
        }
    }
    
    @IBAction func deleteButtonSelected(_ sender: UIButton) {
        if !saveButton.isEnabled {
            if let index = selectedIndex {
                guard let context = self.petInfo?.managedObjectContext else { return }
                let imageToDelete = petImages.remove(at: index)
                context.delete(imageToDelete)
                do {
                    try context.save()
                    self.selectedIndex = nil
                    self.displayImage.image = nil
                    self.imageCollectionView.reloadData()
                } catch {
                    print("Error saving deletion")
                }
            }
        } else {
            self.displayImage.image = nil
            self.saveButton.isEnabled = false
            self.saveTextButton.isEnabled = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

}
