//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/5/21.
//

import UIKit
import MapKit
import CoreData

// MARK : - Travel Locations Map View Controller
class TravelLocationsMapViewController: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setupFetchResultsController()
        showMapAnnotations(fetchedResultsController.fetchedObjects!)
    }
    
    // MARK: - View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapTap(gesture:)))
        
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // MARK: - View Did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //fetchedResultsController = nil
    }
    
    // MARK: - Setup Fetch Results Controller
    fileprivate func setupFetchResultsController() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    // MARK: - Map Tap Long Press Gesture Recognizer
    @objc func mapTap(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            //add pin to map
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            savePin(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    // MARK: - Save Pin
    func savePin(latitude: Double, longitude: Double) {
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude  = latitude
        pin.longitude = longitude
        
        try? dataController.viewContext.save()
        
        setupFetchResultsController()
    }

    
    // MARK: - Show Map Annotations
    func showMapAnnotations(_ pins: [Pin]){
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
}

// MARK: - Extention Map View Delegate
extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    
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

        if let pins = fetchedResultsController.fetchedObjects {
            // there will be only one selected annotation at a time
            let annotation = mapView.selectedAnnotations[0]
            
            // getting the index of the selected annotation to set pin value in destination VC
            guard let indexPath = pins.firstIndex(where: { (pin) -> Bool in
                pin.latitude == annotation.coordinate.latitude && pin.longitude == annotation.coordinate.longitude
            }) else {
                return
            }
            photoAlbumViewController.pin = pins[indexPath]
        }
       
        photoAlbumViewController.dataController = dataController
        
        mapView.deselectAnnotation(view.annotation, animated:true)
        self.navigationController?.pushViewController(photoAlbumViewController, animated: true)
    }
        
    // MARK: - MapView Region Did Change Animated
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
}

// MARK: - Extention Fetch Results Controller Delegate
extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    
}
