//
//  AppDelegate.swift
//  Map-and-points
//
//  Created by Nikita Taranov on 1/16/17.
//  Copyright © 2017 Nikita Taranov. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


@UIApplicationMain



class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let kPlacesAPI = "AIzaSyDqvj7MPZUZV1DNMCSMnzix8wZVUTwNnmI"
    let kMapsAPI = "AIzaSyA8yTsOh930nqkpGSK2i1Ute9D9GYdM8Z8"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("\(kMapsAPI)")
        GMSPlacesClient.provideAPIKey("\(kPlacesAPI)")

    return true
        
    }


}

