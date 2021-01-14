//
//  MapViewController.swift
//  MessageMe
//
//  Created by PuNeet on 13/01/21.
//  Copyright © 2021 dreamsteps. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController {
    //MARK: Vars
    var location: CLLocation?
    var mapView: MKMapView!
    
    
    //MARK: View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureTitle()
        configureMapView()
        configureLeftbarbutton()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: Configuration
    
    private func configureMapView(){
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView.showsUserLocation = true
        
        if location != nil{
            mapView.setCenter(location!.coordinate, animated: false)
            //add annotation
            
            mapView.addAnnotation(MapAnnotation(title: nil, coordinate: location!.coordinate))
        }
        
        view.addSubview(mapView)
    }
    
    private func configureLeftbarbutton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPress))
    }
    
    private func configureTitle(){
        self.title = "Map View"
    }
    
    //MARK: Actions
    
    @objc func backButtonPress(){
        self.navigationController?.popViewController(animated: true)
    }
}
