//
//  MainVC.swift
//  Map-and-points
//
//  Created by Nikita Taranov on 1/16/17.
//  Copyright © 2017 Nikita Taranov. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MainVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate{

    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var pointsTableView: UITableView!
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var finishLocation: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    
    let locationManager = CLLocationManager()
    var pointsArray:Array<Point> = []
    var wpArray:Array<Point> = []
    var currentTextField: UITextField? = nil
    var path = SimplePath(name: "Path", path:[])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        startLocation.delegate = self
        finishLocation.delegate = self
        
        pointsTableView.delegate = self
        pointsTableView.dataSource = self
        
        saveBtn.backgroundColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 0.4)
        clearBtn.backgroundColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 0.4)

        mapView.addSubview(saveBtn)
        mapView.addSubview(clearBtn)

    }
    
    func autoCompleteViewController() {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        self.present(acController, animated: false, completion:nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        autoCompleteViewController()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointCell", for: indexPath) as! PlacesCell

        let name:Point = wpArray[indexPath.row]
        cell.placeName.text = name.name
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.font = UIFont(name: "Futura", size: 15)!
        title.textColor = UIColor.lightGray
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font=title.font
        header.textLabel?.textColor=title.textColor
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{

            return "Waypoints:"
         }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wpArray.count
    }
    
    @IBAction func clearAction(_ sender: Any) {
        
        mapView.clear()
        pointsArray = []
        wpArray = []
        path = SimplePath(name: "Path", path:[])
        startLocation.text = ""
        finishLocation.text = ""
        pointsTableView.reloadData()
        
    }
    
    @IBAction func addPointBtn(_ sender: UIButton) {
        if pointsArray.count < 5 {
            addBtn.isEnabled = true;
            currentTextField = nil
            autoCompleteViewController()
        } else {
            addBtn.isEnabled = false;
            let alert = UIAlertController(title: "Warning", message: "Maximum additional point capability reached", preferredStyle: .alert)
            let yesButton = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            })
            alert.addAction(yesButton)
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func startRouteBtn(_ sender: UIButton) {

        Polyliner().getDataFromServer(withData: pointsArray, completion: { (JSON) in
            Polyliner().drawPolyline(data: JSON, map: self.mapView)
            Polyliner().makeWrooomAndHustle(coordsArray:Polyliner().getCoordsFromEncString(data: JSON) as! Array<[CLLocationCoordinate2D]>,map: self.mapView)
            Marker().placeMarkers(pointsArray: self.pointsArray, map: self.mapView)
        }, failure: { (Error) in
            print(Error)
            })
    }
    
}

extension MainVC: GMSAutocompleteViewControllerDelegate {
 
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        currentTextField?.text = place.name
        if pointsArray.count < 5 {
            let marker = Marker()
            marker.addMarkerPoint(marker: marker, place: place, map: mapView)
            let point = Point(name: place.name, placeID: place.placeID, coords: place.coordinate,marker: marker)
            pointsArray = SimplePath(name: place.name, path: pointsArray).addPointToArray(point: point)
            cameraBounds().bounds(pointArray: pointsArray, map: mapView)
            wpArray = Array(pointsArray.dropFirst(2))
            pointsTableView.reloadData()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error)
        self.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension MainVC: CLLocationManagerDelegate {
   
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {

            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {

            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

            locationManager.stopUpdatingLocation()
        }
    }
}
