//
//  CollectionViewDelegateDS.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 11/06/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation
import UIKit

// MARK: CollectionView Data Source & Delegate
extension PhotoAlbumViewController {
    
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
