//
//  MedVacViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/25/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class MedVacViewController: UIViewController, UITableViewDataSource, UITabBarDelegate, DismissVCDelegate {
    
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var medVacTableView: UITableView!
    
    var pet: Pet? = nil
    var delegate: DismissVCDelegate? = nil
    var medVac: MedVac = .vaccine

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        switch medVac {
        case .medicine:
            self.petNameLabel.text = (self.pet?.name ?? "Pet") + "'s Medicines"
        case .vaccine:
            self.petNameLabel.text = (self.pet?.name ?? "Pet") + "'s Vaccines"
        }
    }
    
    func setupTableView() {
        self.medVacTableView.rowHeight = 100
        let nib = UINib(nibName: "MedVacCell", bundle: nil)
        self.medVacTableView.register(nib, forCellReuseIdentifier: "medVacCell")
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.delegate?.dismissVC(object: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addMedVacVC" {
            guard let addMedVacVC = segue.destination as? AddMedVacViewController else {return}
            addMedVacVC.delegate = self
            addMedVacVC.medOrVac = medVac
            addMedVacVC.pet = pet
        }
    }
    
    // MARK: - DismissVC
    func dismissVC() {
        self.medVacTableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch medVac {
        case .medicine:
            return pet?.health?.medicine?.count ?? 0
        case .vaccine:
            return pet?.health?.vaccines?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "medVacCell", for: indexPath) as! MedVacCell
        switch medVac {
        case .medicine:
            cell.medicine = pet?.health?.medicine?.allObjects[indexPath.row] as? Medicine
        case .vaccine:
            cell.vaccine = pet?.health?.vaccines?.allObjects[indexPath.row] as? Vaccines
        }
        
        return cell
    }

}
