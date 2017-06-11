//
//  DownloadingFunctions.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 11/06/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation
import UIKit

extension PhotoAlbumViewController {
    
    // MARK: Image downloading functions
    func downloadImagesURLsForPin(_ pinInUse: Pin) {
        let downloadQueue = DispatchQueue(label: "download")
        downloadQueue.async { () -> Void in
            let flickrDownloader = FlickrDownloader()
            flickrDownloader.downloadImagesByCoordinates(latitude: pinInUse.latitude, longitude: pinInUse.longitude, completionHandlerForDownload: {(urlArray, error) in
                
                guard error == nil else {
                    General.sharedInstance.performUpdatesOnMain {
                        General.sharedInstance.showAlert(self, title: "Download error", message: "error?.localizedDescription as Any", actionTitle: Constants.alertDismiss)
                    }
                    return
                }
                for imageUrl in urlArray! {
                    let _ = Photo(photoURL: imageUrl, photo: nil, pin: pinInUse, context: self.appDelegate.stack.mainContext)
                }
                
                self.appDelegate.stack.save()
                
                // Set a label for 'No photos'
                if urlArray?.count == 0 {
                    self.locationNameLabel.text = Constants.noPhotos
                }
            })
            
            General.sharedInstance.performUpdatesOnMain {
                do {
                    try self.appDelegate.stack.mainContext.save()
                } catch {
                    print(error.localizedDescription as Any)
                }
            }
        }
    }
    
    func asyncImageDownload(fromURL url: URL, completionHandler handler: @escaping (_ image: UIImage) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
            
            guard let imageData = try? Data(contentsOf: url) else {
                General.sharedInstance.performUpdatesOnMain {
                    General.sharedInstance.showAlert(self, title: "Download error", message: "Cannot download image from: \(url)", actionTitle: Constants.alertDismiss)
                }
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                print("The data are NOT an image")
                return
            }
            
            General.sharedInstance.performUpdatesOnMain {
                handler(image)
            }
        }
    }
}
