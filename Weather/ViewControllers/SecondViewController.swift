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
    @IBOutlet weak var test: StatusButton!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    var statusOnline: Bool = false
    var detailWeather = WeatherModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityLabel.text = detailWeather.city
        self.tempLabel.text = String(Double(detailWeather.temp - 273.15).rounded())+"°"
        let urlImage = "http://openweathermap.org/img/w/\(detailWeather.icon).png"
        let resours = ImageResource(downloadURL: URL(string: urlImage)!)
        weatherImage.kf.setImage(with: resours)
        if statusOnline == true {
            test.fillColor = UIColor.green
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
