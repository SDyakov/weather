//
//  CurrentCoordinates.swift
//  Weather
//
//  Created by Admin on 07.10.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

struct WeatherModel {
    var latitude: Double
    var longitude: Double
    var city: String
    var temp: Double
    var icon: String
    init() {
        self.latitude = 0
        self.longitude = 0
        self.city = ""
        self.icon = ""
        self.temp = 0
    }
}
