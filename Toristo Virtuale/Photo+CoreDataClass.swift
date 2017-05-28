//
//  Photo+CoreDataClass.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 18/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    // MARK: Initializer
    convenience init(photoURL: String, photo: NSData?, pin: Pin?, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: Constants.photoEntity, in: context) {
            
            // Designated Initializer
            self.init(entity: ent, insertInto: context)
            
            // Set properties
            self.photoURL = photoURL
            if let photo = photo {
                self.photo = photo
            }
            if let pin = pin {
                self.pin = pin
            }
        } else {
            fatalError("Cannot find Entity name")
        }
    }
}
