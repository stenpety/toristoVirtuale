//
//  FlickrDownloader.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 12/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit

class FlickrDownloader: NSObject {
    
    // MARK: Downloading function
    func downloadImagesByCoordinates(latitude: Double, longitude: Double) -> [UIImage] {
        
        var images = [UIImage]()
        
        let session = URLSession.shared
        let urlRequest = URLRequest(url: flickrURLFromParameters(makeFlickrParameters(latitude: latitude, longitude: longitude)))
        
        let task = session.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
            
            // Check for error retuned
            guard error == nil else {
                // TODO: display alert here
                return
            }
            
            // Check for response status
            guard let responseCode = (response as? HTTPURLResponse)?.statusCode, (responseCode >= 200 && responseCode <= 299) else {
                // TODO: display alert here
                return
            }
            
            // Check for data existance
            guard let data = data else {
                // TODO: display alert here
                return
            }
            
            // Parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                // TODO: display alert here
                return
            }
            
            // Check Flickr response for an error
            guard let stat = parsedResult[FlickrConstants.ResponseKeys.status] as? String, stat == FlickrConstants.ResponseValues.okStatus else {
                return
            }
            
            // Check for "photos" key in the response
            guard let photosDictionary = parsedResult[FlickrConstants.ResponseKeys.photos] as? [String:AnyObject] else {
                // TODO: display alert here
                return
            }
            
            // Check for "photo" key in photosDictionary
            guard let photosArray = photosDictionary[FlickrConstants.ResponseKeys.photo] as? [[String: AnyObject]] else {
                // TODO: display alert here
                return
            }
            
            //TODO: return images (URLs?)
            
        })
        
        task.resume()
        return images
    }
    
    
    // MARK: Helper Functions
    // Create a URL for photos download request from parameters
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        // Set URL components to Flickr constants
        var components = URLComponents()
        components.scheme = FlickrConstants.APIScheme
        components.host = FlickrConstants.APIHost
        components.path = FlickrConstants.APIPath
        components.queryItems = [URLQueryItem]()
        
        // Set request parameters
        for (key, value) in parameters {
            components.queryItems!.append(URLQueryItem(name: key, value: "\(value)"))
        }
        return components.url!
    }
    
    // Create a string representation of bound box for Flickr images search
    private func bboxString(latitude: Double, longitude: Double) -> String {
        
        return("\(max(FlickrConstants.searchLatRange.0, latitude - FlickrConstants.searchBBoxHalfHeight)),\(min(FlickrConstants.searchLatRange.1, latitude + FlickrConstants.searchBBoxHalfHeight)),\(max(FlickrConstants.searchLongRange.0, longitude - FlickrConstants.searchBBoxHalfWidth)),\(min(FlickrConstants.searchLongRange.1, longitude + FlickrConstants.searchBBoxHalfWidth))")
    }
    
    // Create a dictionary of Flicker request parameters
    private func makeFlickrParameters(latitude: Double, longitude: Double) -> [String: AnyObject] {
        
        let methodParameters: [String: AnyObject] =
            [FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey as AnyObject,
             FlickrConstants.ParameterKeys.safeSearch: FlickrConstants.ParameterValues.useSafeSearch as AnyObject,
             FlickrConstants.ParameterKeys.boundingBox: bboxString(latitude: latitude, longitude: longitude) as AnyObject,
             FlickrConstants.ParameterKeys.extras: FlickrConstants.ParameterValues.mediumURL as AnyObject,
             FlickrConstants.ParameterKeys.method: FlickrConstants.ParameterValues.searchMethod as AnyObject,
             FlickrConstants.ParameterKeys.format: FlickrConstants.ParameterValues.responseFormat as AnyObject,
             FlickrConstants.ParameterKeys.noJSONCallback: FlickrConstants.ParameterValues.disableJSONCallback as AnyObject]
        
        return methodParameters
    }
    
}
