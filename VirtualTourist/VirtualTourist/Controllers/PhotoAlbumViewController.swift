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

class PhotoAlbumViewController:   UIViewController{

    // MARK: - Outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var photoActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - variables
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var flickrPhoto : [FlickrPhoto] = []
    var totalPages: Int = 1
    let sectionInsets = UIEdgeInsets(top: 5.0,
        left: 5.0,
        bottom: 5.0,
        right: 5.0)
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        //show the location annotation on the map
        self.showMapAnnotation()
        //set the new collection button disable
        self.setupNewCollectionButton(false)
        
    }
    
    // MARK: - View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupFetchedResultsController()
        
        if fetchedResultsController.fetchedObjects!.count == 0 {
            self.getFlickrPhotos()
        }
    }
    
    // MARK: - View Did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.fetchedResultsController = nil
    }
    
    
    // MARK: - New Collection Button Tapped
    @IBAction func newCollectionButtonTapped(sender: Any) {
        self.setupNewCollectionButton(false)
        self.deleteAllPhotos()
        self.getFlickrPhotos()
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
        self.centerMapOnLocation(coordinate)
        
    }
    
    // MARK: - Center Map On Location
    func centerMapOnLocation(_ coordinate: CLLocationCoordinate2D) {
        
        self.mapView.setCenter(coordinate, animated: true)
        let regionRadius: CLLocationDistance = 5000
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        self.mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Get Flickr Photos
    func getFlickrPhotos(){
        self.photoActivityIndicator.isHidden = false
        self.photoActivityIndicator.startAnimating()
        FlickrClient.getPhotos(lat: pin.latitude, long: pin.longitude, totalPages: totalPages, completion: handleFlickrResponse(flickrPhotoList:error:))
    }
    
    // MARK: - Handle Flickr Response
    func handleFlickrResponse(flickrPhotoList: FlickrPhotos?, error: Error?){
        
        if error != nil {
            showFailureMessage(title: "Flickr Image Download", message: "Not possible to get the Flickr Images")
            print(error?.localizedDescription ?? "")
        } else {
            
            self.flickrPhoto = flickrPhotoList!.photo
            self.totalPages = flickrPhotoList!.pages
            
            if self.flickrPhoto.count == 0 {
                self.photoActivityIndicator.stopAnimating()
                addNoImageLabel()
                return
            }
            self.photoActivityIndicator.stopAnimating()
            self.collectionView.reloadData()
            self.setupNewCollectionButton(true)
        }
       
    }
    
    // MARK: - Add No Image Label
    func addNoImageLabel() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        label.center = self.view.center
        label.textAlignment = .center
        label.text = "No Images!"
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
        label.textColor = .darkGray
        self.view.addSubview(label)
    }
    
    // MARK: - Setup New Collection Button
    func setupNewCollectionButton(_ isEnable: Bool){
        self.newCollectionButton.isEnabled = isEnable
    }
    
    
    // MARK: - Add Photos
    func addPhoto(data: Data) {
        
        let photoObj = Photo(context: self.dataController.viewContext)
        photoObj.image = data
        photoObj.pin = self.pin
        do {
            try dataController.viewContext.save()
        } catch {
            showFailureMessage(title: "Add Image", message: "Not possible to add Flickr Images")
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Delete Photo
    func deletePhoto(at indexPath: IndexPath) {
       
        let photoToDelete = fetchedResultsController.object(at: indexPath)
       
        dataController.viewContext.delete(photoToDelete)
        
        do {
            try dataController.viewContext.save()
        } catch {
            showFailureMessage(title: "Delete Image", message: "Not possible to delete the image")
            print(error.localizedDescription)
        }
    
        
    }
   
    // MARK: - Delete All Photos
    func deleteAllPhotos () {
        if let photos = self.fetchedResultsController.fetchedObjects {
            
            for photo in photos {
                dataController.viewContext.performAndWait {
                    self.dataController.viewContext.delete(photo)
                   
                    do {
                        try self.dataController.viewContext.save()
                    } catch {
                        showFailureMessage(title: "Delete Images", message: "Not possible to delete all the images")
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // MARK: -  Show Failure Message
    func showFailureMessage(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
}

// MARK: - Extension : MKMapViewDelegate
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

// MARK: - Extension : UICollectionViewDelegate, UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Number Of Sections In CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        if fetchedResultsController.fetchedObjects!.count  > 0 {
            return  fetchedResultsController.sections?.count ?? 1
        } else {
            return flickrPhoto.count
        }
    }
    
    // MARK: - Collection View  Number Of Items In Section
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if fetchedResultsController.fetchedObjects!.count > 0 {
            return fetchedResultsController.sections?[0].numberOfObjects ?? 0
        } else {
            return  self.flickrPhoto.count
        }
    }
    
    // MARK: - Collection View Cell For Item At
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewPhotoCell", for: indexPath) as! CollectionViewPhotoCell
        
        //cell.imageView.image = UIImage(named: "VirtualTourist_512")
        cell.imageView.contentMode = .scaleAspectFit
        
        if  self.fetchedResultsController.fetchedObjects!.count > 0 {
            let photo =  self.fetchedResultsController.object(at: indexPath)
            
            if let image = photo.image {
                cell.imageView?.image = UIImage(data: image)
            }
        } else {
            
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            
            let photo = self.flickrPhoto[indexPath.row]
            
            FlickrClient.downloadImages(farmId: photo.farm, serverId: photo.server, id: photo.id, secret: photo.secret){ (data, error) in
            
                guard let data = data else {
                    return
                }
                
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()
                    
                    self.addPhoto(data: data)
                    
                    let image = UIImage(data: data)
                    cell.imageView?.image = image
                    
                }
            }
        }
        
        return cell
    }
  
    //MARK: - Collection View Did Selected Item At
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        deletePhoto(at: indexPath)
        collectionView.reloadData()
       
    }
    
}

// MARK: - Extension: NSFetchedResultsControllerDelegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    // MARK: - Setup Fetched Results Controller
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
        
        if (fetchedResultsController.fetchedObjects!.count > 0) {
            self.setupNewCollectionButton(true)
        }
    }
    
    
    // MARK: - Controller NSFetchedResultsController Did Change
   func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
            break
        
        default:
            break
        }
    }
}

// MARK: - Extension: UICollectionViewDelegateFlowLayout
extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {

    // MARK: - Collection View Layout sizeForItemAt
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = 3
        let paddingSpace = sectionInsets.left * itemsPerRow
        let availableWidth = UIScreen.main.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
        
    }
      
    // MARK: - collectionViewLayout insetForSectionAt
    func collectionView(_ collectionView: UICollectionView,
                  layout collectionViewLayout: UICollectionViewLayout,
                  insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // MARK: - collectionViewLayout minimumInteritemSpacingForSectionAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // MARK: - collectionViewLayout minimumLineSpacingForSectionAt
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    

}

