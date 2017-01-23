//
//  SavedDataVC.swift
//  Map-and-points
//
//  Created by Nikita Taranov on 1/23/17.
//  Copyright © 2017 Nikita Taranov. All rights reserved.
//

import UIKit

class SavedDataVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
  
    @IBOutlet weak var savedData: UITableView!
    var wpArray:Array<Any> = []
    
    @IBAction func closeVC(_ sender: Any) {
        dismiss(animated: true, completion: {
            
        })
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "savedRouteCell", for: indexPath) as! SavedDataCell
        
        let name:NSArray = wpArray[indexPath.row] as! NSArray
            cell.pathName.text = "Route \(indexPath.row + 1)"
            cell.startPointName.text = (name[0] as AnyObject).name
            cell.finishPointName.text = (name[1] as AnyObject).name
        if name.count>2 {
            cell.firstWaypointName.text = (name[2] as AnyObject).name
        }
        if name.count>3 {
            cell.secondWaypointName.text = (name[3] as AnyObject).name
        }
        if name.count>4 {
           cell.thirdWaypointName.text = (name[4] as AnyObject).name
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wpArray.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       wpArray = PathArray().readDataRealm()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var indexPath: IndexPath = self.savedData.indexPathForSelectedRow!
        let path = self.wpArray[indexPath.row]
        let destinationVC = segue.destination as! MainVC
        destinationVC.pointsArray = path as! Array<Point>

    }

}
