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

class PhotoAlbumViewController: UIViewController {
    
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
        
        // Get the CoreData stack (from AppDelegate)
        let stack = appDelegate.stack
        
        // Create a FetchRequest
        let photosFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.photoEntity)
        photosFetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.keyPhotoURLForPhoto, ascending: true)]

        let photosForPinPred = NSPredicate(format: "pin = %@", argumentArray: [pinInUse])
        photosFetchRequest.predicate = photosForPinPred
        
        // Setup FetchedRequestController (which context??)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: photosFetchRequest, managedObjectContext: stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Check whether there are photos associated with the pin received. Download if not
        do {
            try fetchedResultsController?.performFetch()
            
            if fetchedResultsController?.fetchedObjects?.count == 0 {
                
                // Download pictures URLs in background queue
                let downloadQueue = DispatchQueue(label: "download")
                downloadQueue.async { () -> Void in
                    let flickrDownloader = FlickrDownloader()
                    flickrDownloader.downloadImagesByCoordinates(latitude: pinInUse.latitude, longitude: pinInUse.longitude, completionHandlerForDownload: {(urlArray, error) in
                        
                        guard error == nil else {
                            print(error?.localizedDescription as Any)
                            return
                        }
                        for imageUrl in urlArray! {
                            let _ = Photo(photoURL: imageUrl, photo: nil, pin: pinInUse, context: stack.mainContext)
                        }
                        self.appDelegate.stack.save()
                    })
                    do {
                        try stack.mainContext.save()
                    } catch {
                        print(error.localizedDescription as Any)
                    }
                }
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
        
        // Set a label for 'No photos'
        if fetchedResultsController?.fetchedObjects?.count == 0 {
            locationNameLabel.text = Constants.noPhotos
        }
        
        photoAlbumCollectionView.reloadData() // Reload collection to reflect changes
    }
    
    // MARK: Actions
    // Delete an item from Collection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: delete an item
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Cannot perform fetch")
        }
        let moc = fetchedResultsController?.managedObjectContext
        moc?.delete(fetchedResultsController?.object(at: indexPath) as! NSManagedObject)
    }
    
    // Download new collection
    @IBAction func makeNewCollection(_ sender: UIButton) {
        // TODO: start request to download new photos
        // Nullify existing photos
        
        // Download new photos
        
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

// MARK: CollectionView Data Source & Delegate
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.photoAlbumCollectionItem, for: indexPath) as! PhotoAlbumCollectionViewCell
        let photo = fetchedResultsController?.fetchedObjects?[indexPath.item] as! Photo
        
        // Check whether photo (image) already exists
        if photo.photo != nil {
            cell.photoImageView.image = UIImage(data: photo.photo! as Data)
        } else {
            // Display a placeholder
            cell.photoImageView.image = #imageLiteral(resourceName: "ImagePlaceholder")
            
            // TODO: Download photo in background queue
            guard let url = URL(string: photo.photoURL!) else {
                print("URL \(String(describing: photo.photoURL)) is not valid")
                return cell // ?
            }
            
            asyncImageDownload(fromURL: url, completionHandler: {(image) -> Void in
                guard let imageData = UIImageJPEGRepresentation(image, 1) else {
                    print("Cannot convert image to data")
                    return
                }
                photo.photo = imageData as NSData
                })
            
        }
        return cell
    }
}

extension PhotoAlbumViewController {
    
    // MARK: Image downloading functions
    func asyncImageDownload(fromURL url: URL, completionHandler handler: @escaping (_ image: UIImage) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
            
            guard let imageData = try? Data(contentsOf: url) else {
                print("Cannot download image from: \(url)")
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                print("The data are NOT an image")
                return
            }
            
            performUIUpdatesOnMain {
                handler(image)
            }
        }
    }
}

// MARK: Fetched Results Controller Delegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    // Put change operation into BlockOperations
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.photoAlbumCollectionView!.deleteItems(at: [indexPath!])
                }
                }))
        case .insert:
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.photoAlbumCollectionView!.insertItems(at: [newIndexPath!])
                }
            }))
        case .move:
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.photoAlbumCollectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                }
            }))
        case .update:
            blockOperations.append(BlockOperation(block: { [weak self] in
                if let this = self {
                    this.photoAlbumCollectionView!.reloadItems(at: [indexPath!])
                }
            }))
        }
    }
    
    // Start BlockOperations
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photoAlbumCollectionView!.performBatchUpdates({ () -> Void in
            
            // Disable NewCollection button
            self.newCollectionButton.isEnabled = false
            
            // Start all collected block operations
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
            self.newCollectionButton.isEnabled = true
        })
    }
}
