//
//  TravelMapViewController.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 07/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController {
    
    // MARK: Properties
    
    // MARK: Outlets
    @IBOutlet weak var travelMapView: MKMapView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check whether the app has been launcehd before. Set user coordinates to defaults otherwise
        if !UserDefaults.standard.bool(forKey: Constants.hasLaunchedBefore) {
            UserDefaults.standard.set(true, forKey: Constants.hasLaunchedBefore)
            UserDefaults.standard.set(Constants.defaultLatitude, forKey: Constants.userLatitude)
            UserDefaults.standard.set(Constants.defaultLongitude, forKey: Constants.userLongitude)
            UserDefaults.standard.set(Constants.defaultMapScale, forKey: Constants.userMapScale)
            UserDefaults.standard.synchronize()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Center map on user's current (or default) location
        let userCoordinates = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: Constants.userLatitude), longitude: UserDefaults.standard.double(forKey: Constants.userLongitude))
        let region = MKCoordinateRegionMakeWithDistance(userCoordinates, UserDefaults.standard.double(forKey: Constants.userMapScale), UserDefaults.standard.double(forKey: Constants.userMapScale))
        travelMapView.setRegion(region, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save current map position to UserDefaults
        UserDefaults.standard.set(travelMapView.region.center.latitude, forKey: Constants.userLatitude)
        UserDefaults.standard.set(travelMapView.region.center.longitude, forKey: Constants.userLongitude)
        UserDefaults.standard.set(travelMapView.region.span.latitudeDelta * Constants.metersInOneLatDegree, forKey: Constants.userMapScale)
        UserDefaults.standard.synchronize()
        
        print("Map position saved")
    }
    
    
}

