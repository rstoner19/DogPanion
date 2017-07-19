//
//  GeneralExtensions.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/9/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UITextField {
    func addBarToKeyboard(message: String, viewController: UIViewController) {
        let toolBar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.width, height: 40))
        toolBar.barStyle = UIBarStyle.default
        let keyBoardMessage = UILabel(frame: CGRect(x: toolBar.layer.frame.midX - 100, y: toolBar.frame.midY - 10, width: 200, height: 20))
        keyBoardMessage.textAlignment = .center
        keyBoardMessage.text = message
        toolBar.addSubview(keyBoardMessage)
        toolBar.sizeToFit()
        self.inputAccessoryView = toolBar
    }
}

extension PetLocationsViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        getSearchResults(searchText: searchController.searchBar.text!)
    }
}
