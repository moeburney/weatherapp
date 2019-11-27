//
//  City.swift
//  weatherapp
//
//  Created by Burney, Moe (AU - Sydney) on 26/11/19.
//  Copyright © 2019 Burney, Moe (AU - Sydney). All rights reserved.
//

import Foundation
import CoreLocation

struct City: Codable {
    var id: Int
    var name: String
    var country: String
    var coord: Coord
    var location: CLLocation
    {
        get { return CLLocation(latitude: coord.lat, longitude: coord.lon) }
    }
}

struct Coord: Codable {
    var lat: Double
    var lon: Double
}
