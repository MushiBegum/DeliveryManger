//
//  PinCodeViewController.swift
//  Delivery Manager
//
//  Created by Sohan Chunduru on 6/25/17.
//  Copyright © 2017 Sohan Chunduru. All rights reserved.
//

import UIKit
import GoogleMaps


class PinCodeViewController: UIViewController{
    @IBOutlet weak var input: UILabel!
    var mPasscodeString = [Character]()
    var passcodeString = [Character]()
    let numerickeys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

    @IBOutlet weak var inputLabel: UITextField!
   

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickOnNumberButtons(sender: UIButton) {
        let key = "\(sender.tag)"
        
        if numerickeys.contains(key) {
            
            passcodeString.append(key.characters.first!)
            mPasscodeString.append("*")
            inputLabel?.text = String(mPasscodeString)
            
        } else if key == "11" {
            if passcodeString.count > 0 {
                passcodeString.remove(at: passcodeString.count - 1)
                mPasscodeString.remove(at: mPasscodeString.count - 1)
                inputLabel?.text = String(mPasscodeString)
            }
        }
        
        if passcodeString.count == 4 {
            let passcode = getPasscode()
            if passcode.characters.count == 0 || passcode == String(passcodeString) {
                savePasscodeToUserDefault(value: String(passcodeString))
                
                performSegue(withIdentifier: "signedIn", sender: self)
                
                return
            }
            
            inputLabel?.text = ""
            passcodeString = [Character]()
            mPasscodeString = [Character]()
        }
    }
    func savePasscodeToUserDefault(value: String) {
        
        UserDefaults.standard.set(value, forKey: "passcode")
    }
    
    func getPasscode() -> String {
        if let value = UserDefaults.standard.string(forKey: "passcode") {
            return value
        }
        return ""
    }
    
}
