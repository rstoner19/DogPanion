//
//  AddImageViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/8/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit
import AVFoundation


class AddImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        isAvailable()
    }
    
    func isAvailable() {
        photoLibraryButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary) ? true : false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera) ? true : false
    }
    
    // MARK: - Navigation
    
    func presentImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
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
                self.checkAccess()
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
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    

}
