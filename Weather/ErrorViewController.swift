//
//  ErrorViewController.swift
//  Weather
//
//  Created by Admin on 09.10.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    var error: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = error!
        // Do any additional setup after loading the view.
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
