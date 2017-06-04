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
    func downloadImagesByCoordinates(latitude: Double, longitude: Double, completionHandlerForDownload: @escaping (_ result: [String]?, _ error: NSError?) -> Void) -> Void {
        
        var imageURLs = [String]()
        
        let session = URLSession.shared
        let urlRequest = URLRequest(url: flickrURLFromParameters(makeFlickrParameters(latitude: latitude, longitude: longitude)))
        
        let task = session.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
            
            // Aux function to send errors
            func sendError(_ errorString: String) {
                let userInfo = [NSLocalizedDescriptionKey:errorString]
                completionHandlerForDownload(nil, NSError(domain: "downloadImagesByCoordinates", code: 1, userInfo: userInfo))
            }
            
            // Check for error retuned
            guard error == nil else {
                sendError((error?.localizedDescription)!)
                return
            }
            
            // Check for response status
            guard let responseCode = (response as? HTTPURLResponse)?.statusCode, (responseCode >= 200 && responseCode <= 299) else {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    switch statusCode {
                    case 403: sendError("Forbidden: wrong username/password")
                    case 404: sendError("Not found")
                    case 405: sendError("Method not allowed")
                    default: sendError("Bad status code: \(statusCode)")
                    }
                } else {
                    sendError("Request returned a status code other than 2xx")
                }
                return
            }
            
            // Check for data existance
            guard let data = data else {
                sendError("Request returned no data")
                return
            }
            
            // Parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                sendError("Couldn't parse returned data")
                return
            }
            
            // Check Flickr response for an error
            guard let stat = parsedResult[FlickrConstants.ResponseKeys.status] as? String, stat == FlickrConstants.ResponseValues.okStatus else {

                if let stat = parsedResult[FlickrConstants.ResponseKeys.status] as? String, stat == FlickrConstants.ResponseValues.failStatus {
                    let badStatus = "Bad Flickr status: \(stat). Details: \(parsedResult[FlickrConstants.ResponseKeys.message]!)"
                    sendError(badStatus)
                } else {
                    sendError("Flickr response status is other than OK!")
                }
                return
            }
            
            // Check for "photos" key in the response
            guard let photosDictionary = parsedResult[FlickrConstants.ResponseKeys.photos] as? [String:AnyObject] else {
                sendError("No 'Photos' key found in parsed data")
                return
            }
            
            // Check for "photo" key in photosDictionary
            guard let photosArray = photosDictionary[FlickrConstants.ResponseKeys.photo] as? [[String: AnyObject]] else {
                sendError("No 'Photo' key found in parsed data")
                return
            }
            
            // Iterate through photo array and add URLs to resulting array
            for photo in photosArray {
                if let photoURLString = photo[FlickrConstants.ResponseKeys.mediumURL] as? String {
                    imageURLs.append(photoURLString)
                }
            }
            completionHandlerForDownload(imageURLs, nil)
        })
        task.resume()
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
        
        return("\(max(FlickrConstants.searchLongRange.0, longitude - FlickrConstants.searchBBoxHalfWidth)),\(max(FlickrConstants.searchLatRange.0, latitude - FlickrConstants.searchBBoxHalfHeight)),\(min(FlickrConstants.searchLongRange.1, longitude + FlickrConstants.searchBBoxHalfWidth)),\(min(FlickrConstants.searchLatRange.1, latitude + FlickrConstants.searchBBoxHalfHeight))")
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
             FlickrConstants.ParameterKeys.noJSONCallback: FlickrConstants.ParameterValues.disableJSONCallback as AnyObject,
             FlickrConstants.ParameterKeys.perPage: FlickrConstants.ParameterValues.numberOfPhotosPerPage as AnyObject]
        return methodParameters
    }
}
