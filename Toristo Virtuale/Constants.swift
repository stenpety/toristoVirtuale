//
//  Constants.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 10/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit
import CoreData

struct Constants {
    
    // Empty private init to prohibit initialization of this struct
    private init() {}
    
    // Storyboard Identifiers
    static let segueShowPhotoAlbum = "showPhotoAlbum"
    static let photoAlbumCollectionItem = "photoAlbumCollectionItem"
    static let photoAlbumViewController = "photoAlbumViewController"
    static let pinAnnotationView = "pinAnnotationView"
    
    // Collection view constants
    static let initialNumberOfCellsInRow = 3
    static let collectionMinInteritemSpace: CGFloat = 3
    static let collectionMinLineSpace: CGFloat = 3
    static let collectionViewTitle = "My memories"
    static let noPhotos = "No Country for Old Men"
    
    // UserDefaults keys
    static let hasLaunchedBefore = "hasLaunchedBefore"
    static let userLatitude = "userLAtitude"
    static let userLongitude = "userLongitude"
    static let userMapScale = "userMapScale"
    
    // Defaults for map
    static let defaultMapScale: Double = 500000
    static let defaultMiniMapScale: Double = 2500
    static let defaultLatitude = -37.814
    static let defaultLongitude = 144.96332
    static let defaultMinPressDuration = 1.0 // Min press duration for LongPress recognizer
    static let defaultLocationName = "Unknown location"
    static let defaultLocalityName = "Unknown region"
    
    // Auxiliary items
    static let metersInOneLatDegree: Double = 111131
    
    // Files, folders
    static let modelName = "Toristo_Virtuale"
    static let modelExtension = "momd"
    static let sqliteStoreName = "Toristo_Virtuale.sqlite"
    
    // DataBase
    // Options for migration
    static let optionsForMigration = [NSInferMappingModelAutomaticallyOption: true,
                                      NSMigratePersistentStoresAutomaticallyOption: true]
    // Entities
    static let photoEntity = "Photo"
    static let pinEntity = "Pin"
    // Keys
    static let keyLatitudeForPin = "latitude"
    static let keyLongitudeForPin = "longitude"
    static let keyLocationNameForPin = "locationName"
    static let keyPhotoForPhoto = "photo"
    static let keyPhotoURLForPhoto = "photoURL"
}

struct FlickrConstants {
    
    // Empty private init to prohibit initialization of this struct
    private init() {}
    
    // URL parameters
    static let APIScheme = "https"
    static let APIHost = "api.flickr.com"
    static let APIPath = "/services/rest"
    
    // Parameters for making bounding box (geo location search)
    static let searchBBoxHalfHeight = 0.1
    static let searchBBoxHalfWidth = 0.1
    static let searchLatRange = (-90.0, 90.0)
    static let searchLongRange = (-180.0, 180.0)
    
    struct ParameterKeys {
        static let APIKey = "api_key"
        static let safeSearch = "safe_search"
        static let boundingBox = "bbox"
        static let extras = "extras"
        static let method = "method"
        static let format = "format"
        static let noJSONCallback = "nojsoncallback"
    }
    
    struct ParameterValues {
        static let APIKey = "8ffa07e46f6c16f300c46b15fc3a58c2"
        static let useSafeSearch = "1"
        static let mediumURL = "url_m"
        static let searchMethod = "flickr.photos.search"
        static let responseFormat = "json"
        static let disableJSONCallback = "1"
    }
    
    struct ResponseKeys {
        static let status = "stat"
        static let photos = "photos"
        static let photo = "photo"
        static let title = "title"
        static let mediumURL = "url_m"
        static let message = "message" // For debug - read stat fail details
        //static let pages = "pages"
        //static let total = "total"
    }
    
    struct ResponseValues {
        static let okStatus = "ok"
        static let failStatus = "fail"
    }
    
}
