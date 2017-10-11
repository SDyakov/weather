//
//  WheatherJson.swift
//  Weather
//
//  Created by Admin on 07.10.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import ObjectMapper

class WheatherJson: Mappable {
    var city: String?
    var temp: Double?
    var icon: String?
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        city <- map["name"]
        temp <- map["main.temp"]
        icon <- map["weather.0.icon"]
    }
}
