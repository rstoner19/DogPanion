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
    
    func getHour() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = "h a"
        return formatter.string(from: self)
    }
    
    func addHalfDay() -> Date {
        return self.addingTimeInterval(43200)
    }
    
    func addDay() -> Date {
        return self.addingTimeInterval(86400)
    }
    
    func addWeek() -> Date {
        return self.addingTimeInterval(604800)
    }
    
    func addMonth() -> Date {
        var components = DateComponents()
        components.setValue(1, for: .month)
        let calendar = Calendar.current
        return calendar.date(byAdding: components, to: self)!
    }
    
    func addQuarter() -> Date {
        var components = DateComponents()
        components.setValue(3, for: .month)
        let calendar = Calendar.current
        return calendar.date(byAdding: components, to: self)!
    }
    
    func addHalfYear() -> Date {
        var components = DateComponents()
        components.setValue(6, for: .month)
        let calendar = Calendar.current
        return calendar.date(byAdding: components, to: self)!
    }
    
    func addYear() -> Date {
        var components = DateComponents()
        components.setValue(1, for: .year)
        let calendar = Calendar.current
        return calendar.date(byAdding: components, to: self)!
    }
}

extension Double {
    
    func toString() -> String {
        return String(format: "%.0f", self)
    }
}

extension CGPoint {
    func adding(x: CGFloat) -> CGPoint { return CGPoint(x: self.x + x, y: self.y) }
    func adding(y: CGFloat) -> CGPoint { return CGPoint(x: self.x, y: self.y + y) }
}

extension PetLocationsViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        getSearchResults(searchText: searchController.searchBar.text!)
    }
}

extension String {
    func toDate() -> Date? {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.date(from: self)
    }
    
    func size(withSystemFontSize pointSize: CGFloat) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: pointSize)])
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
