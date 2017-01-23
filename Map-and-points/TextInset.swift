//
//  TextInset.swift
//  Map-and-points
//
//  Created by Nikita Taranov on 1/23/17.
//  Copyright © 2017 Nikita Taranov. All rights reserved.
//

import UIKit

private var designKey = false

extension UITextField {
    
    @IBInspectable var textInset: Bool{
        
        get{
            return designKey
        }
        
        set {
            designKey = newValue
            
            if designKey {
                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: self.frame.height))
                self.leftView = paddingView
                self.leftViewMode = UITextFieldViewMode.always
            } else {
                self.leftView = nil
                self.leftViewMode = UITextFieldViewMode.always
            }
        }
    }
}
