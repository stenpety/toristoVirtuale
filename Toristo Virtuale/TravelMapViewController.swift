//
//  TravelMapViewController.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 07/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: Properties
    let locationManager = CLLocationManager()
    
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
            UserDefaults.standard.synchronize()
        }
        
        // Setup Location manager (to get user coordinates)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        // Start location manager
        CLLocationManager.locationServicesEnabled()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Center map on user's current (or default) location
        let userCoordinates = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: Constants.userLatitude), longitude: UserDefaults.standard.double(forKey: Constants.userLongitude))
        let region = MKCoordinateRegionMakeWithDistance(userCoordinates, Constants.defaultMapScale, Constants.defaultMapScale)
        travelMapView.setRegion(region, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save current map position to UserDefaults
        UserDefaults.standard.set(travelMapView.region.center.latitude, forKey: Constants.userLatitude)
        UserDefaults.standard.set(travelMapView.region.center.longitude, forKey: Constants.userLongitude)
        
        // Stop location manager
        locationManager.stopUpdatingLocation()
    }
    
    
    
    // MARK: Location Manager Delegate
    // Get user coordinates and update UserDefaults
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        UserDefaults.standard.set(userLocation.coordinate.latitude, forKey: Constants.userLatitude)
        UserDefaults.standard.set(userLocation.coordinate.longitude, forKey: Constants.userLongitude)
    }
    
}

