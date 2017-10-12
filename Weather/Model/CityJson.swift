//
//  CityJson.swift
//  Weather
//
//  Created by Admin on 07.10.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import ObjectMapper

class CityJson: Mappable {
    var city: String?
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        city <- map["response.GeoObjectCollection.featureMember.0.GeoObject.metaDataProperty.GeocoderMetaData.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.LocalityName"]
    }
}
