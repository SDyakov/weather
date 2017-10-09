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

class ViewController: UIViewController , CLLocationManagerDelegate{
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    let location = CLLocationManager()
    let currentDate = NSDate()
    var coordinate = CurrentCoordinates(latitude: 0, longitude: 0, city:"", temp: 0, icon: "")

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        coordinate.latitude = locations[0].coordinate.latitude
        coordinate.longitude =  locations[0].coordinate.longitude
        let url = "https://geocode-maps.yandex.ru/1.x/?format=json&geocode=\(coordinate.longitude),\(coordinate.latitude)"
         Alamofire.request(url).validate().responseObject { (response: DataResponse<CityJson>) in
            self.coordinate.city = response.result.value!.city!
            //Convert Cirilic on ACI
            let csCopy = CharacterSet(bitmapRepresentation: CharacterSet.urlPathAllowed.bitmapRepresentation)
            let escapedString = self.coordinate.city.addingPercentEncoding(withAllowedCharacters: csCopy)!
            let url2 = "http://api.openweathermap.org/data/2.5/weather?q=\(escapedString)&appid=8754af81a8466413734c0a814cffc82f"
            if response.result.isSuccess {
                    Alamofire.request(url2).responseObject { (response: DataResponse<WheatherJson>) in
                        self.coordinate.city = response.result.value!.city!
                        self.coordinate.temp = response.result.value!.temp!
                        self.coordinate.icon = response.result.value!.icon!
                        if response.result.isSuccess {
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            let contex = appDelegate.persistentContainer.viewContext
                            let newWeather = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: contex)
                            newWeather.setValue(self.coordinate.city, forKey: "city")
                            newWeather.setValue(self.coordinate.icon, forKey: "icon")
                            newWeather.setValue(self.coordinate.temp, forKey: "temp")
                            newWeather.setValue(self.currentDate, forKey: "dateInsert")
                            do {
                                try contex.save()
                                print("Saved")
                            
                            }
                            catch {
                                
                            }
                            
                        }
                      //  self.getDataFromDataBase()
                        self.performSegue(withIdentifier: "segue", sender: self )
                        self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    

  /*  func insertDataBase(_ city: String, _ temp : Double, _ icon: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let contex = appDelegate.persistentContainer.viewContext
        let newWeather = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: contex)
        newWeather.setValue(city, forKey: "city")
        newWeather.setValue(icon, forKey: "icon")
        newWeather.setValue(temp, forKey: "temp")
        
        do {
            	try contex.save()
                print("Saved")
                return true
        }
        catch {
               return false
        }
       
    }*/
    
    func getDataFromDataBase() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let contex = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        
        request.returnsObjectsAsFaults = false
        
        do {
             let result = try contex.fetch(request)
            let res = result.last as! NSManagedObject
            print(res.value(forKey: "city")!,"   ",res.value(forKey: "icon")!,"   ",res.value(forKey: "temp")!,"   ",res.value(forKey: "dateInsert")!)
            let dateLastInsert = res.value(forKey: "dateInsert") as! NSDate
            print(dateLastInsert)
            let inter = currentDate.timeIntervalSince(dateLastInsert as Date)
            print(inter)
}
        catch {
            
        }
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let secondController = segue.destination as! SecondViewController
        secondController.detailWeather.city = coordinate.city
        secondController.detailWeather.icon = coordinate.icon
        secondController.detailWeather.temp = coordinate.temp
    }
    
    func  updateLocation() {
        
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
        location.requestWhenInUseAuthorization()
        location.startUpdatingLocation()
        location.stopUpdatingLocation()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
 
    }
    
    //@IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let contex = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        var interval: TimeInterval = 0
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try contex.fetch(request)
            let res = result.last as! NSManagedObject
            print(res.value(forKey: "city")!,"   ",res.value(forKey: "icon")!,"   ",res.value(forKey: "temp")!,"   ",res.value(forKey: "dateInsert")!)
            coordinate.city = res.value(forKey: "city")! as! String
            coordinate.icon = res.value(forKey: "icon")! as! String
            coordinate.temp = res.value(forKey: "temp")! as! Double
            let dateLastInsert = res.value(forKey: "dateInsert") as! NSDate
            print(dateLastInsert)
            interval = currentDate.timeIntervalSince(dateLastInsert as Date)
            print(interval)
        }
        catch {
            
        }
        if interval<6 {
            self.performSegue(withIdentifier: "segue", sender: self )
        }
        else
        {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        super.viewDidLoad()
        updateLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

