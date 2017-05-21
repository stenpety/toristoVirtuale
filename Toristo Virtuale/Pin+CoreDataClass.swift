//
//  Pin+CoreDataClass.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 18/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    // MARK: Initializer
    convenience init(latitude: Double, longitude: Double, locationName: String?, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Constants.pinEntity, in: context) {
            // Designated Initializer
            self.init(entity: ent, insertInto: context)
            
            // Set properties
            self.latitude = latitude
            self.longitude = longitude
            if let locationName = locationName {
                self.locationName = locationName
            }
        } else {
            fatalError("Unable to find Entity name")
        }
    }
    
}
