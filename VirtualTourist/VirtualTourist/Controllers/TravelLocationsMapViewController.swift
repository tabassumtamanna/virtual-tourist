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
    
    // MARK: - MapView View For Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // MARK: - MapView View Did Select
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        let photoAlbumViewController = self.storyboard?.instantiateViewController(identifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        
        photoAlbumViewController.latitude =  Float((view.annotation?.coordinate.latitude)!)
        photoAlbumViewController.longitude = Float((view.annotation?.coordinate.longitude)!)
        
        self.navigationController?.pushViewController(photoAlbumViewController, animated: true)
    }
        
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
}

