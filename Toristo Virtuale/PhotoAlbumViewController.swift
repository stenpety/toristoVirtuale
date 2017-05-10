//
//  PhotoAlbumViewController.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 10/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var auxMapView: MKMapView!
    @IBOutlet weak var photoAlbumCollection: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
