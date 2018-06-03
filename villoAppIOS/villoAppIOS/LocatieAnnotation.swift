//
//  LocatieAnnotation.swift
//  villoAppIOS
//
//  Created by Anaïs Willems on 3/06/18.
//  Copyright © 2018 Cedric Willems. All rights reserved.
//

import UIKit
import MapKit

class LocatieAnnotation: NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }

}
