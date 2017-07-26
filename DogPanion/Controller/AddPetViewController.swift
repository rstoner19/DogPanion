//
//  AddPetViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/11/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class AddPetViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var petNameTextField: UITextField!
    @IBOutlet weak var dogBreedTextField: UITextField!
    
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    weak var delegate: DismissVCDelegate? = nil
    var newPet: Pet? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setup() {
        self.petNameTextField.becomeFirstResponder()
        self.petNameTextField.delegate = self
        self.dogBreedTextField.delegate = self
        self.doneButton.addBorder(color: .black, width: 0.5, radius: 3)
        self.addImageButton.addBorder(color: .black, width: 0.5, radius: 3)
    }
    
    @IBAction func petNameTextField(_ sender: UITextField) {
        self.petNameLabel.text = sender.text
    }
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        self.petNameTextField.becomeFirstResponder()
    }
    @IBAction func nextStepButtonClicked(_ sender: UIButton) {
        let context = appDelegate.persistentContainer.viewContext
        newPet = Pet(context: context)
        newPet?.name = self.petNameLabel.text
        newPet?.breed = self.dogBreedTextField.text
        newPet?.health = Health(context: context)
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
            self.alert(message: "Error Saving Information", title: "Sorry, but there was an error saving your pet information.  Please try again")
            return
        }
        sender == addImageButton ? performSegue(withIdentifier: "addImageVC", sender: nil) : self.delegate?.dismissVC()
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addImageVC" {
            guard let addImageVC = segue.destination as? AddImageViewController else {return}
            addImageVC.delegate = delegate
            addImageVC.petInfo = newPet
        }
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.petNameTextField {
            self.dogBreedTextField.isEnabled = true
        }
        return self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.petNameTextField {
            self.petNameLabel.text = ""
            textField.addBarToKeyboard(message: "Enter Pet Name", viewController: self, buttons: false)
        }
    }
    

}
