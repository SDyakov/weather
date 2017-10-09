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
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var labelTemp: UILabel!
    
    
    let location = CLLocationManager()
    var coordinate = CurrentCoordinates(latitude: 0, longitude: 0, city:"", temp: 0, icon: "")
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        coordinate.latitude = locations[0].coordinate.latitude
        coordinate.longitude =  locations[0].coordinate.longitude
        print (coordinate.latitude, coordinate.longitude)
        let url = "https://geocode-maps.yandex.ru/1.x/?format=json&geocode=\(coordinate.longitude),\(coordinate.latitude)"
        print(url)
         Alamofire.request(url).validate().responseObject { (response: DataResponse<CityJson>) in
            debugPrint("All Response Info: \(response)")
            self.coordinate.city = response.result.value!.city!
            //Convert Cirilic on ACI
            let csCopy = CharacterSet(bitmapRepresentation: CharacterSet.urlPathAllowed.bitmapRepresentation)
            let escapedString = self.coordinate.city.addingPercentEncoding(withAllowedCharacters: csCopy)!
           // let cityEnc = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            print(response.result.value!.city!)
            let url2 = "http://api.openweathermap.org/data/2.5/weather?q=\(escapedString)&appid=8754af81a8466413734c0a814cffc82f"
            print(url2)
            if response.result.isSuccess {
                    Alamofire.request(url2).responseObject { (response: DataResponse<WheatherJson>) in
                    debugPrint(response)
                    print (response.result.value!.city!)
                    print (response.result.value!.temp!)
                        self.coordinate.city = response.result.value!.city!
                        self.coordinate.temp = response.result.value!.temp!
                        self.coordinate.icon = response.result.value!.icon!
                      //  print(self.coordinate.city,"  ",self.coordinate.temp,"   ",self.coordinate.icon)
                }
            }
        }
    }
    @IBAction func saveButton(_ sender: UIButton) {
       print(insertDataBase(coordinate.city, coordinate.temp, coordinate.icon))
    }
    
    @IBAction func fetchButton(_ sender: UIButton) {
        getDataFromDataBase()
        loadImage()
    }
    func insertDataBase(_ city: String, _ temp : Double, _ icon: String) -> Bool {
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
       
    }
    
    func getDataFromDataBase() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let contex = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        
        request.returnsObjectsAsFaults = false
        
        do {
             let result = try contex.fetch(request)
            let res = result.last as! NSManagedObject
            print(res.value(forKey: "city")!,"   ",res.value(forKey: "icon")!,"   ",res.value(forKey: "temp")!)
          //  print(result.first!)
        }
        catch {
            
        }
        
    }
    
    func loadImage() {
        let urlImage = "http://openweathermap.org/img/w/\(coordinate.icon).png"
        let resours = ImageResource(downloadURL: URL(string: urlImage)!)
        imageView.kf.setImage(with: resours)
        labelCity.text = coordinate.city
        labelTemp.text = String(coordinate.temp-273.15)
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
        super.viewDidLoad()
        updateLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

