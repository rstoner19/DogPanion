//
//  ImageCustomFlowLayout.swift
//  DogPanion
//
//  Created by Rick Stoner on 7/15/17.
//  Copyright © 2017 Rick Stoner. All rights reserved.
//

import UIKit

class ImageCustomFlowLayout: UICollectionViewFlowLayout {
    
    let columns: Int
    let space: CGFloat
    
    init(columns: Int = 3, space: CGFloat = 1) {
        self.columns = columns
        self.space = space
        super.init()
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.minimumLineSpacing = self.space
        self.minimumInteritemSpacing = self.space
        self.itemSize = CGSize(width: self.itemWidth(), height: self.itemWidth())
    }
    
    func itemWidth() -> CGFloat {
        let width = UIScreen.main.bounds.width
        let availableWidth = width - (CGFloat(self.columns) * self.space)
        return availableWidth / CGFloat(self.columns)
    }

}
