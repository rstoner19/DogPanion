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
