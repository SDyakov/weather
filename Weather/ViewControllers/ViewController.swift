//
//  ViewController.swift
//  WeatherForecast
//
//  Created by Admin on 07.10.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import CoreData
import Kingfisher
import SystemConfiguration
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let locationManager = CLLocationManager()
    var infoError: String = ""
    var weatherModel = WeatherModel()
    var status: Bool = false
    var interval: TimeInterval = 0
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        weatherModel.latitude = locations[0].coordinate.latitude
        weatherModel.longitude =  locations[0].coordinate.longitude
        let urlGeocoder = "\(weatherModel.prefixGeocoder)\(weatherModel.longitude),\(weatherModel.latitude)"
        if isInternetAvailable() == true {
         Alamofire.request(urlGeocoder).validate().responseObject { (response: DataResponse<CityJson>) in
            if response.result.isSuccess {
            self.weatherModel.city = response.result.value!.city!
            let csRuleURLPathAllow = CharacterSet(bitmapRepresentation: CharacterSet.urlPathAllowed.bitmapRepresentation)
            let convertStringCity = self.weatherModel.city.addingPercentEncoding(withAllowedCharacters: csRuleURLPathAllow)!
            let urlWeatherService = "\(self.weatherModel.prefixWeatherService)\(convertStringCity)\(self.weatherModel.postfixWeatherService)"
                Alamofire.request(urlWeatherService).responseObject { (response: DataResponse<WeatherJson>) in
                    if response.result.isSuccess {
                        self.weatherModel.city = response.result.value!.city!
                        self.weatherModel.temp = response.result.value!.temp!
                        self.weatherModel.icon = response.result.value!.icon!
                        self.addToDataBase()
                        self.status = true
                        self.performSegue(withIdentifier: "segue", sender: self )
                        self.activityIndicator.stopAnimating()
                   } else {
                        self.infoError = "Impossible to get weather data."
                        self.performSegue(withIdentifier: "errorSegue", sender: self)
                   }
              }
           } else {
                self.infoError = "Can't define city."
                self.performSegue(withIdentifier: "errorSegue", sender: self)
            }
        }
        } else {
            self.infoError = "Network Problem."
            self.performSegue(withIdentifier: "errorSegue", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            let secondController = (segue.destination as? SecondViewController)!
            secondController.detailWeather.city = weatherModel.city
            secondController.detailWeather.icon = weatherModel.icon
            secondController.detailWeather.temp = weatherModel.temp
            secondController.statusOnline = status
        }
        if segue.identifier == "errorSegue" {
            let errorController = (segue.destination as? ErrorViewController)!
            errorController.error = infoError
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.status = false
        getFromDataBase()
        if self.interval<600 {
            self.performSegue(withIdentifier: "segue", sender: self )
        } else {
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       if status != CLAuthorizationStatus.denied {
            locationManager.startUpdatingLocation()
        } else {
            infoError = "In the settings, enable the use of geolocation. Restart the application."
            self.performSegue(withIdentifier: "errorSegue", sender: self)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Fuction
    func addToDataBase() {
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        let contex = appDelegate.persistentContainer.viewContext
        let newWeather = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: contex)
        let currentDate = NSDate()
        newWeather.setValue(self.weatherModel.city, forKey: "city")
        newWeather.setValue(self.weatherModel.icon, forKey: "icon")
        newWeather.setValue(self.weatherModel.temp, forKey: "temp")
        newWeather.setValue(currentDate, forKey: "dateInsert")
        do {
            try contex.save()
        } catch {
            self.infoError = "Impossible to save weather data."
            self.performSegue(withIdentifier: "errorSegue", sender: self)
        }
    }
    func getFromDataBase() {
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        let contex = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        request.returnsObjectsAsFaults = false
        do {
            let result = try contex.fetch(request)
            let res = result.last as? NSManagedObject
            if res != nil {
                weatherModel.city = (res?.value(forKey: "city") as? String)!
                weatherModel.icon = (res?.value(forKey: "icon") as? String)!
                weatherModel.temp = (res?.value(forKey: "temp") as? Double)!
                let dateLastInsert = (res?.value(forKey: "dateInsert") as? NSDate)!
                let currentDate = NSDate()
                self.interval = currentDate.timeIntervalSince(dateLastInsert as Date)
            } else {
                self.interval = 600
            }
        } catch {
        }
    }
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
