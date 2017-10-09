//
//  SecondViewController.swift
//  Weather
//
//  Created by Admin on 09.10.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Kingfisher

class SecondViewController: UIViewController {
 
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    var detailWeather = CurrentCoordinates(latitude: 0, longitude: 0, city: "", temp: 0, icon: "")
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.cityLabel.text = detailWeather.city
        self.tempLabel.text = String(detailWeather.temp - 273.15)
        let urlImage = "http://openweathermap.org/img/w/\(detailWeather.icon).png"
        let resours = ImageResource(downloadURL: URL(string: urlImage)!)
        weatherImage.kf.setImage(with: resours)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
