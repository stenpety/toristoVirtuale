//
//  PhotoAlbumViewController.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 10/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Properties
    var numberOfCellsInRow = Constants.initialNumberOfCellsInRow // Set to initial value 3
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var pinForAlbum: Pin? = nil //Values to be obtained from TravelMapVC
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            photoAlbumCollectionView.reloadData()
        }
    }
    
    var blockOperations = [BlockOperation]()
    
    // MARK: Outlets
    @IBOutlet weak var auxMapView: MKMapView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    @IBOutlet weak var photoAlbumFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    // MARK: Initializers
    init (fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.fetchedResultsController = fetchedResultsController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Collection view
        setupFlowLayout()
        photoAlbumCollectionView.delegate = self
        photoAlbumCollectionView.dataSource = self
        
        // Set the title of this view
        title = Constants.collectionViewTitle
        
        // Check whether 'pin' data were obtained
        guard let pinInUse = pinForAlbum else {
            fatalError("Pin was not transmitted!")
        }
        
        // Create a FetchRequest
        let photosFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.photoEntity)
        photosFetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.keyPhotoURLForPhoto, ascending: true)]

        let photosForPinPred = NSPredicate(format: "pin = %@", argumentArray: [pinInUse])
        photosFetchRequest.predicate = photosForPinPred
        
        // Setup FetchedRequestController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: photosFetchRequest, managedObjectContext: appDelegate.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Check whether there are photos associated with the pin received. Download if not
        do {
            try fetchedResultsController?.performFetch()
            
            if fetchedResultsController?.fetchedObjects?.count == 0 {
                
                // Download pictures URLs in background queue
                downloadImagesURLsForPin(pinInUse)
            }
        } catch {
            fatalError("Cannot fetch photos!")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup mini-map, label, and NewCollection button
        guard let pinInUse = pinForAlbum else {
            fatalError("Pin was not transmitted!")
        }
        locationNameLabel.text = pinInUse.locationName
        
        // Center mini-map on user's new pin location:
        let pinInUseCoordinates = CLLocationCoordinate2D(latitude: pinInUse.latitude, longitude: pinInUse.longitude)
        let region = MKCoordinateRegionMakeWithDistance(pinInUseCoordinates, Constants.defaultMiniMapScale, Constants.defaultMiniMapScale)
        auxMapView.setRegion(region, animated: false)
        
        // Set a pin
        let miniMapPin = MKPointAnnotation()
        miniMapPin.coordinate = pinInUseCoordinates
        miniMapPin.title = pinInUse.locationName
        auxMapView.addAnnotation(miniMapPin)
        
        photoAlbumCollectionView.reloadData() // Reload collection to reflect changes
    }
    
    // MARK: Actions
    // Delete an item from Collection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Cannot perform fetch")
        }
        let moc = fetchedResultsController?.managedObjectContext
        moc?.delete(fetchedResultsController?.object(at: indexPath) as! NSManagedObject)
        appDelegate.stack.save()
    }
    
    // Download new collection
    @IBAction func makeNewCollection(_ sender: UIButton) {
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Cannot perform fetch")
        }
        let moc = fetchedResultsController?.managedObjectContext
        
        // Nullify existing photos
        for object in (fetchedResultsController?.fetchedObjects)! {
            moc?.delete(object as! NSManagedObject)
            }
        appDelegate.stack.save()
        
        // Download new photos
        guard let pinInUse = pinForAlbum else {
            fatalError("Pin was not transmitted!")
        }
        downloadImagesURLsForPin(pinInUse)
    }
    
    // MARK: Auxiliary procedures
    func setupFlowLayout() {
        // Setup Inter-item & line spacing to defaults
        photoAlbumFlowLayout.minimumInteritemSpacing = Constants.collectionMinInteritemSpace
        photoAlbumFlowLayout.minimumLineSpacing = Constants.collectionMinLineSpace
        
        // Set item width with respect to the number of items in row
        let dimension = ((photoAlbumCollectionView.frame.size.width) - CGFloat(numberOfCellsInRow - 1) * Constants.collectionMinInteritemSpace) / CGFloat(numberOfCellsInRow)
        photoAlbumFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}
