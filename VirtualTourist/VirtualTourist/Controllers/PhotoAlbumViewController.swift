//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/17/21.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController:   UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    // MARK: - variables
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        print("lat: \(latitude), long: \(longitude)")
        //show the location annotation on the map
        showMapAnnotation()
        
        //getFlickrPhotos()
        
        
        let space:CGFloat = 3.0
        
        let dimension = (view.frame.size.width - (2 * space)) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        print(flowLayout.itemSize)
    }
    
    

    // MARK: - Show Map Annotation
    func showMapAnnotation(){
        
        //set the latitude and longitude
        let lat = CLLocationDegrees(self.latitude)
        let long = CLLocationDegrees(self.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        self.mapView.addAnnotation(annotation)
        self.mapView.selectAnnotation(annotation, animated: true)
        
        //zooms the map into the location region
        centerMapOnLocation(coordinate)
        
    }
    
    // MARK: - Center Map On Location
    func centerMapOnLocation(_ coordinate: CLLocationCoordinate2D) {
        
        self.mapView.setCenter(coordinate, animated: true)
        let regionRadius: CLLocationDistance = 3000
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    func getFlickrPhotos(){
        FlickrClient.getPhotos(lat: self.latitude, long: self.longitude, completion: handleFlickrResponse(flickrPhoto:error:))
    }
    
    func handleFlickrResponse(flickrPhoto: [FlickrPhoto], error: Error?){
        if error == nil {
            print(flickrPhoto)
        }
    }
    
    
}


extension PhotoAlbumViewController: MKMapViewDelegate {
    
    
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
    
}


extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: - Collection View  Number Of Items In Section
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    // MARK: - Collection View Cell For Item At
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        
        //cell.imageView?.image = UIImage(named: "pict_large")
        return cell
    }
    
    //MARK: - Collection View Did Selected Item At
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
    }
    
}
