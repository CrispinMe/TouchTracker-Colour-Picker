//
//  Line.swift
//  TouchTracker
//
//  Created by Crispin Lloyd on 01/01/2020.
//  Copyright © 2020 Big Nerd Ranch. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

struct Line {
    var begin = CGPoint.zero
    var end = CGPoint.zero
    
    //Computed property to hold the angle of the line
    var lineAngle: Double {
        get {
            if (end.y - begin.y) / (end.x - begin.x) < 0 {
              return Double(atan((end.y - begin.y) / (end.x - begin.x))*50)
                
            } else {
                
                return Double(atan((end.y - begin.y) / (end.x - begin.x))*50)
                
            }
        }
                    
    }
    
    //Create stored property to hold the colour for the line - black is the default colour
    var lineColor: UIColor = UIColor.black

    
}
