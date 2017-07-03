//
//  PinCodeViewController.swift
//  Delivery Manager
//
//  Created by Sohan Chunduru on 6/25/17.
//  Copyright © 2017 Sohan Chunduru. All rights reserved.
//

import UIKit
import GoogleMaps
class PinCodeViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
   
    
    @IBAction func Numbers(_ sender: UIButton) {
        label.text = label.text! + String(sender.tag-1)
        
    }
    
    @IBAction func EnterButton(_ sender: AnyObject) {
        if label.text == "0000" {
            performSegue(withIdentifier: "signedIn", sender: self)
        }
    }

    @IBAction func backspaceButton(_ sender: UIButton) {
        if label.text != "" && sender.tag == 11{
            resetLabel()
        }
    }
    
    func resetLabel(){
        label.text = ""
}
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
}
}
