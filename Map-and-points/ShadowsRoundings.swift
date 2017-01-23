//
//  ShadowsRoundings.swift
//  Map-and-points
//
//  Created by Nikita Taranov on 1/22/17.
//  Copyright © 2017 Nikita Taranov. All rights reserved.
//

import UIKit

private var designKey = false

extension UIView {

    @IBInspectable var shadowsRoundings: Bool{
        
        get{
            return designKey
        }
        
        set {
            designKey = newValue
            
            if designKey {
                self.layer.masksToBounds = false
                self.layer.cornerRadius = 3.0
                self.layer.shadowOpacity = 0.8
                self.layer.shadowRadius = 1.0
                self.layer.shadowOffset = CGSize(width: 0, height: 2)
                self.layer.shadowColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1.0).cgColor
            } else {
                self.layer.cornerRadius = 0
                self.layer.shadowOpacity = 0
                self.layer.shadowRadius = 0
                self.layer.shadowColor = nil
            }
        }
    }
}
