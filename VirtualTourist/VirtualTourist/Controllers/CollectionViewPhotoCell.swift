//
//  CollectionViewPhotoCell.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/19/21.
//

import UIKit

// MARK: - Collection View Photo Cell
class CollectionViewPhotoCell: UICollectionViewCell {
    
    // MARK: - Outlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
