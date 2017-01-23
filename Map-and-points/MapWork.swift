//
//  MapWork.swift
//  Map-and-points
//
//  Created by Nikita Taranov on 1/18/17.
//  Copyright © 2017 Nikita Taranov. All rights reserved.
//

import GoogleMaps
import Alamofire
import CoreLocation
import GooglePlaces

class Marker:GMSMarker {

    var marker:Marker {
        return self.marker
    }
    
    func addMarkerPoint(marker:GMSMarker,place: GMSPlace,map:GMSMapView){
        
            marker.title = place.name
            marker.position = place.coordinate
            marker.map = map
    }
    
    func createMarker(name:String,coords: CLLocationCoordinate2D) -> Marker{
        let marker = Marker()
        marker.title = name
        marker.position = coords
        return marker
    }
    
    func placeMarkers(pointsArray:Array<Point>,map:GMSMapView){
        
        for marker:Point in pointsArray {
            marker.marker.map = map
        }
        
    }
    
}

class cameraBounds {
    
    func bounds(pointArray:Array<Point>,map:GMSMapView) -> () {
        
        if pointArray.count>0 {
            var bounds = GMSCoordinateBounds()
            for point in pointArray {
                 bounds = bounds.includingCoordinate(point.coords)
            }
            map.animate(with: GMSCameraUpdate.fit(bounds))
        }
    }
}

class Polyliner {

    func decodePolyline(encodedPolyline: String, precision: Double = 1e5) -> [CLLocationCoordinate2D]? {
        
        let data = encodedPolyline.data(using: String.Encoding.utf8)!
        
        let byteArray = unsafeBitCast((data as NSData).bytes, to: UnsafePointer<Int8>.self)
        let length = Int(data.count)
        var position = Int(0)
        var decodedCoordinates = [CLLocationCoordinate2D]()
        
        var lat = 0.0
        var lon = 0.0
        
        while position < length {
            
            do {
                let resultingLat = try decodeSingleCoordinate(byteArray: byteArray, length: length, position: &position, precision: precision)
                lat += resultingLat
                
                let resultingLon = try decodeSingleCoordinate(byteArray: byteArray, length: length, position: &position, precision: precision)
                lon += resultingLon
            } catch {
                return nil
            }
            
            decodedCoordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        
        return decodedCoordinates
    }
    
    private func decodeSingleCoordinate(byteArray: UnsafePointer<Int8>, length: Int, position: inout Int, precision: Double = 1e5) throws -> Double {
        
        guard position < length else { throw PolylineError.singleCoordinateDecodingError }
        let bitMask = Int8(0x1F)
        var coordinate: Int32 = 0
        var currentChar: Int8
        var componentCounter: Int32 = 0
        var component: Int32 = 0
        
        repeat {
            currentChar = byteArray[position] - 63
            component = Int32(currentChar & bitMask)
            coordinate |= (component << (5*componentCounter))
            position += 1
            componentCounter += 1
        } while ((currentChar & 0x20) == 0x20) && (position < length) && (componentCounter < 6)
        
        if (componentCounter == 6) && ((currentChar & 0x20) == 0x20) {
            throw PolylineError.singleCoordinateDecodingError
        }
        
        if (coordinate & 0x01) == 0x01 {
            coordinate = ~(coordinate >> 1)
        } else {
            coordinate = coordinate >> 1
        }
        
        return Double(coordinate) / precision
    }
    
    enum PolylineError: Error {
        case singleCoordinateDecodingError
    }
    
    
    
    func drawPolyline(data:Any, map:GMSMapView) {
        map.clear()
        DispatchQueue.global(qos: .background).async {
            let parse = (((data as? NSDictionary)?["routes"] as? NSArray)?[0] as? NSDictionary)?["legs"] as? NSArray
            for x in 0..<parse!.count{
                let steps = (parse?[x] as? NSDictionary)?["steps"] as? NSArray
                for x in 0..<steps!.count{
                    let locString = (((steps![x] as? NSDictionary)?["polyline"] as? NSDictionary)?["points"]) as! String
                    DispatchQueue.main.async {
                    self.drawRoute(locString: locString, map: map)
                    }
                }
            }
        }
    }
    
    func getCoordsFromEncString(data:Any) -> Array<[CLLocationCoordinate2D]?>{
       
        var pointsArray:Array<[CLLocationCoordinate2D]?> = []
            let parse = (((data as? NSDictionary)?["routes"] as? NSArray)?[0] as? NSDictionary)?["legs"] as? NSArray
            for x in 0..<parse!.count{
                let steps = (parse?[x] as? NSDictionary)?["steps"] as? NSArray
                for x in 0..<steps!.count{
                    let locString = (((steps![x] as? NSDictionary)?["polyline"] as? NSDictionary)?["points"]) as! String
                    pointsArray.append(self.decodePolyline(encodedPolyline: locString))
                }
            }
        return pointsArray
    }
    
    func drawRoute(locString:String, map:GMSMapView) {
        let routePolyline = GMSPolyline(path: GMSPath(fromEncodedPath: locString))
        routePolyline.map = map
    }
    
    func makeWrooomAndHustle(coordsArray:Array<[CLLocationCoordinate2D]>,map:GMSMapView) {
        var fullrouteArray:Array<CLLocationCoordinate2D> = []
        for array:Array<CLLocationCoordinate2D> in coordsArray {
            for obj in array {
                fullrouteArray.append(obj)
            }
        }
        let queue = DispatchQueue.global(qos: .default)
        queue.async(execute: {() -> Void in
            for obj: CLLocationCoordinate2D in fullrouteArray {
                DispatchQueue.main.sync(execute: {() -> Void in
                   self.updateLocationoordinates(coordinates: obj, map:map)
                })
            }
        })
    }
    var destinationMarker:GMSMarker?
    func updateLocationoordinates(coordinates: CLLocationCoordinate2D,map: GMSMapView) {

        if destinationMarker == nil
        {
            destinationMarker = GMSMarker()
            destinationMarker?.position = coordinates
            let image = UIImage(named:"shevy-1")
            destinationMarker?.icon = image
            destinationMarker?.map = map
            destinationMarker?.appearAnimation = kGMSMarkerAnimationPop
        }
        else
        {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.destinationMarker?.position =  coordinates
                Thread.sleep(forTimeInterval: 0.008)
            })
            CATransaction.setAnimationDuration(0.005)
        }
        CATransaction.commit()
    }

    func getDataFromServer(withData data: [Point], completion: @escaping (_ JSON: Any) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let BASE_URL = "https://maps.googleapis.com/maps/api/directions/json?"
        var ORIGIN = "&origin=place_id:"
        var DESTINATION = "&destination=place_id:"
        var WAYPOINTS = "&waypoints=optimize:false|"
        let API_KEY = "&key=AIzaSyDqvj7MPZUZV1DNMCSMnzix8wZVUTwNnmI"
        
        var pointsData: [Point] = data
            if pointsData.count>1 {
                ORIGIN += "\(pointsData[0].placeID)"
                DESTINATION += "\(pointsData[1].placeID)"
                
                pointsData = Array(pointsData.dropFirst(2))
                
                for point in pointsData {
                    WAYPOINTS += "place_id:\(point.placeID)|"
                }
                let CURRENT_URL = "\(BASE_URL)\(ORIGIN)\(DESTINATION)\(WAYPOINTS)\(API_KEY)"
                let set = CharacterSet.urlQueryAllowed
                let currentURL = URL(string: CURRENT_URL.addingPercentEncoding(withAllowedCharacters: set)!)!
                Alamofire.request(currentURL).responseJSON{ response in
                    completion(response.value!);
                }
            }
    }
    
}


