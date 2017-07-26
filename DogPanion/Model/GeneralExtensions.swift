//
//  GeneralExtensions.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/9/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

extension PetLocationsViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        getSearchResults(searchText: searchController.searchBar.text!)
    }
}

extension UIButton {
    func addBorder(color: UIColor, width: CGFloat, radius: CGFloat?) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        self.layer.cornerRadius = radius ?? 0
    }
}

extension UIViewController {
    func alert(message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func doneButtonPressed() {
        print("hmmmm")
        self.resignFirstResponder()
    }
}

extension UITextField {
    func addBarToKeyboard(message: String, viewController: UIViewController, buttons: Bool) {
        let toolBar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.width, height: 40))
        toolBar.barStyle = UIBarStyle.blackTranslucent
        let keyBoardMessage = UILabel(frame: CGRect(x: toolBar.layer.frame.midX - 100, y: toolBar.frame.midY - 10, width: 200, height: 20))
        keyBoardMessage.textAlignment = .center
        keyBoardMessage.textColor = UIColor.white
        keyBoardMessage.text = message
        if buttons == true {
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(viewController.resignFirstResponder))
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(viewController.view.endEditing(_:)))
            let items = [cancel, flexSpace, done]
            toolBar.items = items
        }
        toolBar.addSubview(keyBoardMessage)
        toolBar.sizeToFit()
        self.inputAccessoryView = toolBar
    }
}
