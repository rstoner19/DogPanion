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
    
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    

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
        self.petNameLabel.text = petInfo?.name
        if let images = petInfo?.images {
            petImages = PetImages.renderImage(imageDate: PetImages.orderImagesByDate(images: images))
        }
    }
    
    func isAvailable() {
        photoLibraryButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary) ? true : false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera) ? true : false
    }
    
    var petImages: [UIImage]? = nil {
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
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch  authStatus {
        case .authorized:
            presentImagePicker(.camera)
        case .denied:
            self.alert(message: "Access to Camera Denied. To allow access go to Setting > DogPanion allow access to camera.", title: "Access Denied")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (_) in
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
        imageCollectionView.collectionViewLayout = ImageCustomFlowLayout(columns: 4, space: 2)
        imageCollectionView.layer.borderColor = UIColor.black.cgColor
        imageCollectionView.layer.borderWidth = 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petInfo?.images?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "petImagesCell", for: indexPath) as! PetImageCell
        if let petImage = petInfo?.images?.allObjects[indexPath.row] as? PetImages {
            let value = petImage.image as Data
            guard let image = UIImage.init(data: value) else { return cell }
            cell.petImage.image = image
            cell.petImage.contentMode = .scaleAspectFill
        }
        return cell
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let context = self.petInfo?.managedObjectContext else { return }
        let images = PetImages(context: context)
        images.date = Date() as NSDate
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        images.image = UIImageJPEGRepresentation(selectedImage, 1.0)! as NSData
        if let pet = self.petInfo {
            pet.addToImages(images)
            do {
                try context.save()
            } catch {
                self.alert(message: "Error Saving", title: "Sorry, there was an error saving the image, please tray again.")
            }
        } // TODO: Ensure to fix issues with camera returning sideways shots
        if let newImages = CoreDataManager.shared.fetchImages(context: context) {
            self.petImages = PetImages.renderImage(imageDate: newImages)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    

}
