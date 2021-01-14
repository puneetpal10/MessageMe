//
//  LocationManager.swift
//  MessageMe
//
//  Created by PuNeet on 13/01/21.
//  Copyright © 2021 dreamsteps. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate{
    
    static let shared = LocationManager()
    var locationManager : CLLocationManager?
    var currentLocation : CLLocationCoordinate2D?
    private override init() {
        super.init()
        // ask permission
        requestLocationAccess()
    }
    
    func requestLocationAccess(){
        if locationManager == nil{
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    
    func startUpdating(){
        locationManager!.startUpdatingLocation()
    }
    
    func stopUpdating(){
        if locationManager != nil{
            locationManager!.stopUpdatingHeading()
        }
    }
    
    
    
    //MARK: Delegates
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to get location")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!.coordinate
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            if manager.authorizationStatus == .notDetermined{
                self.locationManager!.requestWhenInUseAuthorization()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
