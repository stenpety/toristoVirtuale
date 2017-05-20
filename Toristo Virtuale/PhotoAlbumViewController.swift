//
//  PhotoAlbumViewController.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 10/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UICollectionViewController {
    
    // MARK: Properties
    var numberOfCellsInRow = Constants.initialNumberOfCellsInRow // Set to initial value 3
    
    
    // MARK: Outlets
    @IBOutlet weak var auxMapView: MKMapView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var photoAlbumCollection: UICollectionView!
    @IBOutlet weak var photoAlbumFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    // MARK: Auxiliary procedures
    func setupFlowLayout() {
        // Setup Inter-item & line spacing to defaults
        photoAlbumFlowLayout.minimumInteritemSpacing = Constants.collectionMinInteritemSpace
        photoAlbumFlowLayout.minimumLineSpacing = Constants.collectionMinLineSpace
        
        // Set item width with respect to the number of items in row
        let dimension = ((photoAlbumCollection?.frame.size.width)! - CGFloat(numberOfCellsInRow - 1) * Constants.collectionMinInteritemSpace) / CGFloat(numberOfCellsInRow)
        photoAlbumFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}
