//
//  ViewController.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/4/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit



class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DismissVCDelegate {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var petCollectionView: UICollectionView!
    
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var imagesButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    @IBOutlet weak var bottomSecBG: UIImageView!
    @IBOutlet weak var collectionViewBG: UIImageView!
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var arrow: UIImageView!
    
    
    // TODO: Need default image is user hasn't added any.
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var petImages: [PetImages] = []
    var currentIndexPath: IndexPath = IndexPath(row: 1, section: 0)
    var reverse: Bool = false
    var selectedPet: Int = 0
    
    var pet: [Pet]? = nil {
        didSet {
            if pet?.count ?? 0 > 0 {
                if let images = pet?[selectedPet].images {
                    petImages = PetImages.orderImagesByDate(images: images)
                }
                imageCollectionView.reloadData()
                petCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfPet()
    }
    
    func setup() {
        roundButtons()
        pet = CoreDataManager.shared.fetchPets()
    }
    
    func roundButtons() {
        func buttonFormat(button: UIButton) -> UIButton {
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.cornerRadius = 40
            return button
        }
        healthButton = buttonFormat(button: healthButton)
        mapButton = buttonFormat(button: mapButton)
        imagesButton = buttonFormat(button: imagesButton)
    }
    
    func checkIfPet() {
        if pet?.count == 0 {
            enableButtons(enabled: false)
            self.animateImage()
        } else {
            enableButtons(enabled: true)
            adjustArrows(index: selectedPet)
        }
    }
    
    func animateImage() {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            self.arrow.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { (_) in
            UIView.animate(withDuration: 0.4, animations: {
                self.arrow.transform = CGAffineTransform(scaleX: 0.833, y: 0.833)
            })
        })
    }
    
    func enableButtons(enabled: Bool) {
        self.healthButton.isEnabled = enabled
        self.mapButton.isEnabled = enabled
        self.imagesButton.isEnabled = enabled
        self.arrow.isHidden = enabled
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addImageVC" {
            guard let addImageVC = segue.destination as? AddImageViewController else { return }
            addImageVC.delegate = self
            addImageVC.petInfo = pet?[selectedPet]
            petImages = []
        } else if segue.identifier == "addPetVC" {
            guard let addPetVC = segue.destination as? AddPetViewController else { return }
            addPetVC.delegate = self
        } else if segue.identifier == "petLocations" {
            guard let petLocationsVC = segue.destination as? PetLocationsViewController else { return }
            petLocationsVC.delegate = self
        } else if segue.identifier == "healthVC" {
            guard let healthVC = segue.destination as? HealthViewController else { return }
            healthVC.delegate = self
        }
    }
    
    // MARK: Dismiss Delegate
    func dismissVC() {
        self.dismiss(animated: true) {
            self.pet = CoreDataManager.shared.fetchPets()
            self.currentIndexPath.row = 0 
            self.checkIfPet()
        }
    }
    
    // MARK: UICollectionView
    func setupCollectionView() {
        let screen = UIScreen.main.bounds
        let firstLayout = setLayout(width: screen.width, height: screen.height * 0.5, spacing: 0)
        imageCollectionView.collectionViewLayout = firstLayout
        imageCollectionView.layer.borderColor = UIColor.black.cgColor
        imageCollectionView.layer.borderWidth = 1
        let secondLayout = setLayout(width: screen.width * 0.39, height: screen.height * 0.1, spacing: 1)
        petCollectionView.collectionViewLayout = secondLayout
        scrollImage()
    }
    
    func setLayout(width: CGFloat, height: CGFloat, spacing: CGFloat) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let number = pet?.count ?? 0 > 0 ? pet?[selectedPet].images?.count ?? 1 : 1
        return collectionView == imageCollectionView ? number == 0 ? 1 : number : pet?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imageCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "petImageCell", for: indexPath) as! PetImageCell
            cell.petImage.image = petImages.count > 0 ? UIImage(data: petImages[indexPath.row % petImages.count].image as Data) : pet?.count == 0 ? UIImage(named: "welcomeBG") : UIImage(named: "addImageBG")
            cell.petImage.contentMode = .scaleAspectFill
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "petNameCell", for: indexPath) as! PetNameCell
            if let pet = pet {
                cell.nameLabel.text = pet[indexPath.row].name
            }
            return cell
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == imageCollectionView {
            if self.currentIndexPath.row == petImages.count - 1 { reverse = true }
            if self.currentIndexPath.row == 0 && reverse == true { reverse = false }
            self.currentIndexPath.row = reverse == true ?  self.currentIndexPath.row - 1 : self.currentIndexPath.row + 1
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == petCollectionView {
            let selectedIndexPath = indexInView(collection: self.petCollectionView)
            if self.selectedPet != selectedIndexPath {
                adjustArrows(index: selectedIndexPath)
                self.selectedPet = selectedIndexPath
                self.currentIndexPath.row = 0
                if let images = pet?[selectedPet].images {
                    petImages = PetImages.orderImagesByDate(images: images)
                }
                imageCollectionView.scrollToItem(at: self.currentIndexPath, at: .centeredHorizontally, animated: false)
                self.imageCollectionView.reloadData()
            }
        }
    }
    
    func scrollImage() {
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MainViewController.switchImage), userInfo: nil, repeats: true)
    }
    
    func adjustArrows(index: Int) {
        if pet?.count ?? 0 > 1 {
            switch index {
            case 0:
                self.leftArrow.isHidden = true
                self.rightArrow.isHidden = false
            case pet!.count - 1:
                self.rightArrow.isHidden = true
                self.leftArrow.isHidden = false
            default:
                self.rightArrow.isHidden = false
                self.leftArrow.isHidden = false
            }
        }
    }
    
    func indexInView(collection: UICollectionView) -> Int {
        var visiblePortion = CGRect()
        visiblePortion.origin = collection.contentOffset
        visiblePortion.size = collection.bounds.size
        let visiblePoint = CGPoint(x: visiblePortion.midX, y: visiblePortion.midY)
        return  collection.indexPathForItem(at: visiblePoint)?.row ?? 0
    }
    
    @objc func switchImage() {
        if petImages.count > 1 {
            if indexInView(collection: imageCollectionView) == self.currentIndexPath.row {self.currentIndexPath.row = 1 }
            self.imageCollectionView.scrollToItem(at: self.currentIndexPath, at: .centeredHorizontally, animated: true)
        } else if pet?.count ?? 0 == 0 {
            animateImage()
        }
    }
    
}

