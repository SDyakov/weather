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
    let location = CLLocationManager()
    var infoError: String = ""
    var coordinate = CurrentCoordinates(latitude: 0, longitude: 0, city: "", temp: 0, icon: "")
    var status: Bool = false
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location.stopUpdatingLocation()
        coordinate.latitude = locations[0].coordinate.latitude
        coordinate.longitude =  locations[0].coordinate.longitude
        let url = "https://geocode-maps.yandex.ru/1.x/?format=json&geocode=\(coordinate.longitude),\(coordinate.latitude)"
        if isInternetAvailable() == true {
         Alamofire.request(url).validate().responseObject { (response: DataResponse<CityJson>) in
            //debugPrint(response)
            if response.result.isSuccess {
            self.coordinate.city = response.result.value!.city!
            //Convert Cirilic on ACI
            let csCopy = CharacterSet(bitmapRepresentation: CharacterSet.urlPathAllowed.bitmapRepresentation)
            let escapedString = self.coordinate.city.addingPercentEncoding(withAllowedCharacters: csCopy)!
                let url2 = "http://api.openweathermap.org/data/2.5/weather?q=\(escapedString)&appid=8754af81a8466413734c0a814cffc82f"
                    Alamofire.request(url2).responseObject { (response: DataResponse<WheatherJson>) in
                        if response.result.isSuccess {
                        self.coordinate.city = response.result.value!.city!
                        self.coordinate.temp = response.result.value!.temp!
                        self.coordinate.icon = response.result.value!.icon!
                        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
                        let contex = appDelegate.persistentContainer.viewContext
                        let newWeather = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: contex)
                        let currentDate = NSDate()
                        newWeather.setValue(self.coordinate.city, forKey: "city")
                        newWeather.setValue(self.coordinate.icon, forKey: "icon")
                        newWeather.setValue(self.coordinate.temp, forKey: "temp")
                        newWeather.setValue(currentDate, forKey: "dateInsert")
                            do {
                                try contex.save()
                                print("Saved")
                                } catch {
                            }
                            self.status = true
                            self.performSegue(withIdentifier: "segue", sender: self )
                            self.activityIndicator.stopAnimating()
                              } else {
                           self.infoError = "Невозможно получить данные о погоде"
                            self.performSegue(withIdentifier: "errorSegue", sender: self)
                        }
                  }
            }
            if response.result.isFailure {
                self.infoError = "Невозможно определить город."
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
            secondController.detailWeather.city = coordinate.city
            secondController.detailWeather.icon = coordinate.icon
            secondController.detailWeather.temp = coordinate.temp
            secondController.statusOnline = status
        }
        if segue.identifier == "errorSegue" {
            let errorController = (segue.destination as? ErrorViewController)!
            errorController.error = infoError
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.status = false
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        let contex = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        var interval: TimeInterval = 0
        request.returnsObjectsAsFaults = false
        do {
            let result = try contex.fetch(request)
            let res = result.last as? NSManagedObject
            if res != nil {
            coordinate.city = (res?.value(forKey: "city") as? String)!
            coordinate.icon = (res?.value(forKey: "icon") as? String)!
            coordinate.temp = (res?.value(forKey: "temp") as? Double)!
            let dateLastInsert = (res?.value(forKey: "dateInsert") as? NSDate)!
            print(dateLastInsert)
            let currentDate = NSDate()
            interval = currentDate.timeIntervalSince(dateLastInsert as Date)
            print(interval)
            } else {
                interval = 600
            }
            } catch {
                }
        if interval<20 {
            self.performSegue(withIdentifier: "segue", sender: self )
        } else {
            print(CLAuthorizationStatus.self)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            location.requestWhenInUseAuthorization()
            location.delegate = self
            location.desiredAccuracy = kCLLocationAccuracyBest
            location.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       if status != CLAuthorizationStatus.denied {
            location.startUpdatingLocation()
        } else {
            infoError = "In the settings, enable the use of geolocation. Restart the application."
            self.performSegue(withIdentifier: "errorSegue", sender: self)
        }
    }
    //@IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
