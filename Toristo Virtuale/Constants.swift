//
//  Constants.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 10/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation

struct Constants {
    
    // Empty private init to prohibit initialization of this struct
    private init() {}
    
    // Storyboard Identifiers
    static let segueShowPhotoAlbum = "showPhotoAlbum"
    static let photoAlbumCollectionItem = "photoAlbumCollectionItem"
    
    
    // UserDefaults keys
    static let hasLaunchedBefore = "hasLaunchedBefore"
    static let userLatitude = "userLAtitude"
    static let userLongitude = "userLongitude"
    static let userMapScale = "userMapScale"
    
    // Auxiliary items
    static let defaultMapScale: Double = 500000
    static let defaultLatitude = -37.814
    static let defaultLongitude = 144.96332
    static let metersInOneLatDegree: Double = 111131
}

struct FlickrConstants {
    
    // Empty private init to prohibit initialization of this struct
    private init() {}
    
    // URL parameters
    static let APIScheme = "https"
    static let APIHost = "api.flickr.com"
    static let APIPath = "/services/rest"
    
    // Parameters for search by coordinates
    static let searchBBoxHalfWidth = 1.0
    static let searchBBoxHalfHeight = 1.0
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
        static let pages = "pages"
        static let total = "total"
    }
    
    struct ResponseValues {
        static let okStatus = "ok"
    }
    
}
