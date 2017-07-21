//
//  PopUpViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/20/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    
    var delegate: DismissVCDelegate? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presentAnimation()
    }

    func setup() {
        self.backgroundView.layer.cornerRadius = 5
        self.backgroundView.layer.borderColor = UIColor.black.cgColor
        self.backgroundView.layer.borderWidth = 1.0
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissVC()
        removeAnimate()
    }
    
    func presentAnimation() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished) {
                self.view.removeFromSuperview()
            }
        });
    }

}
