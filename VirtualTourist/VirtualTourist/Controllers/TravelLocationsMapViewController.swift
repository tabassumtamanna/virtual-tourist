//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/5/21.
//

import UIKit
import MapKit

// MARK : - Travel Locations Map View Controller
class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapTap(gesture:)))
        
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
    }

    
    @objc func mapTap(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
        }
    }
    
    
}

