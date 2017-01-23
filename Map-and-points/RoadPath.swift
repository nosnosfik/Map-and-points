//
//  RoadPath.swift
//  Map-and-points
//
//  Created by Nikita Taranov on 1/16/17.
//  Copyright © 2017 Nikita Taranov. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class Point: NSObject {
    private var _name: String
    private var _placeID: String
    private var _coords: CLLocationCoordinate2D
    private var _marker: Marker
    
    var name:String{
        return _name
    }
    
    var placeID:String{
        return _placeID
    }

    var coords:CLLocationCoordinate2D{
        return _coords
    }
    
    var marker:Marker{
        return _marker
    }
    
    init(name:String, placeID: String, coords:CLLocationCoordinate2D, marker:Marker) {
        _name = name
        _placeID = placeID
        _coords = coords
        _marker = marker
    }
    
    var point:Point {
        return self.point
    }
    
}

class SimplePath {
   
    private var _name: String
    private var _path: Array<Point>
    
    var name:String{
        return _name
    }

    var path: Array<Point> {
        return _path
    }

    init(name:String,path:Array<Point>) {
        _name = name
        _path = path
    }

    func addPointToArray(point:Point) -> Array<Point> {
        let startPoint = point
        if _path.count < 5{
                 _path.append(startPoint)
                
        } 
        return path
    }
}
