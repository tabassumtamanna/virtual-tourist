//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/17/21.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController:   UIViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    // MARK: - variables
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var photos: [Photo] = []
    var flickrPhoto: [FlickrPhoto] = []
    
    let sectionInsets = UIEdgeInsets(top: 5.0,
        left: 5.0,
        bottom: 50.0,
        right: 5.0)
    
    var frameSize: CGSize = CGSize(width: 300.0, height: 300.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        //show the location annotation on the map
        showMapAnnotation()
        
       setupFetchedResultsController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        print("Count: \(fetchedResultsController.fetchedObjects!.count)")
        
        if (fetchedResultsController.fetchedObjects!.count == 0) {
            getFlickrPhotos()
        }
    }
    
    

    // MARK: - Show Map Annotation
    func showMapAnnotation(){
        
        //set the latitude and longitude
        let lat = CLLocationDegrees(pin.latitude)
        let long = CLLocationDegrees(pin.longitude)
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
        let regionRadius: CLLocationDistance = 5000
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    func getFlickrPhotos(){
        FlickrClient.getPhotos(lat: pin.latitude, long: pin.longitude, completion: handleFlickrResponse(flickrPhoto:error:))
    }
    
    func handleFlickrResponse(flickrPhoto: [FlickrPhoto], error: Error?){
        if error != nil {
            print(error?.localizedDescription ?? "")
        } else {
            print("flickrPhoto: \(flickrPhoto)")
            self.flickrPhoto = flickrPhoto
            
            if flickrPhoto.count == 0 {
                
                print("No photo")
                return
            }
            self.collectionView.reloadData()
            self.collectionView.reloadInputViews()
            
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
    
    // MARK: - Number Of Sections In CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return  1
    }
    
    // MARK: - Collection View  Number Of Items In Section
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchedResultsController.fetchedObjects!.count > 0 {
                return fetchedResultsController.fetchedObjects!.count
        } else {
            return flickrPhoto.count
        }
    }
    
    // MARK: - Collection View Cell For Item At
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewPhotoCell", for: indexPath) as! CollectionViewPhotoCell
        
        cell.imageView?.image = UIImage(named: "VirtualTourist_1024")
       
        if fetchedResultsController.fetchedObjects!.count > 0 {
            
            let photo =  fetchedResultsController.object(at: indexPath)
            if let image = photo.image {
                cell.imageView?.image = UIImage(data: image)
            }
        
        } else {
            
            cell.activityIndicator.startAnimating()
            let photo = flickrPhoto[indexPath.row]
            
            FlickrClient.downloadImages(farmId: photo.farm, serverId: photo.server, id: photo.id, secret: photo.secret){ (data, error) in
                
                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()
                    let image = UIImage(data: data)
                    cell.imageView?.image = image
                    
                    //save photo/image
                    let photoObj = Photo(context: self.dataController.viewContext)
                    photoObj.image = data
                    photoObj.pin = self.pin
                    try? self.dataController.viewContext.save()
                    
                }
            }
        }
        
        return cell
    }
    
    //MARK: - Collection View Did Selected Item At
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let paddingSpace = sectionInsets.left * itemsPerRow
        let availableWidth = UIScreen.main.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        frameSize = CGSize(width: widthPerItem, height: widthPerItem)
        
        return frameSize
      }
      
      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
      }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            
            return 0
        }
      
      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
      }
    

}

