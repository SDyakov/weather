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
    let prefixGeocoder: String
    let prefixWeatherService: String
    let postfixWeatherService: String
    init() {
        self.latitude = 0
        self.longitude = 0
        self.city = ""
        self.icon = ""
        self.temp = 0
        self.prefixGeocoder = "https://geocode-maps.yandex.ru/1.x/?format=json&geocode="
        self.prefixWeatherService = "http://api.openweathermap.org/data/2.5/weather?q="
        self.postfixWeatherService = "&appid=8754af81a8466413734c0a814cffc82f"
    }
}
