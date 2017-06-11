//
//  FetchedResultsDelegate.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 11/06/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation
import CoreData


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
