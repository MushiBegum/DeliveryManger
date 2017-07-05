//
//  ViewController.swift
//  Delivery Manager
//
//  Created by Sohan Chunduru on 6/25/17.
//  Copyright © 2017 Sohan Chunduru. All rights reserved.
//

import UIKit
import SwiftyJSON


class ViewController: UIViewController, UITextFieldDelegate {
    
    
    var userList: [LoginModel] = [LoginModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchUsers()
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    func fetchUsers()
    {
        //Getting the json data
        userList = fetchUserList()
        //Print the data whether its rendering properly
        for user in userList {
            if user.userName == usernameField.text && user.password == passwordField.text {
                 UserDefaults.standard.set(user.userName, forKey: "applicationConnectionID")
                
                performSegue(withIdentifier: "loggedIn", sender: self)
                resetField()
            }
            else
            {
                createAlert(title: "Invalid", message: "Invalid username and/or password, Please try again")
            }
            
        }
        
    }
    private func saveAppLoginDetails(){
        
    }
    
    
    
    //Fetch the json from json.file
    public  func fetchUserList() ->[LoginModel]
    {
        var resultArray = [LoginModel]()
        let resourceFolderPath = Bundle.main.resourcePath
        let fullPath = URL(fileURLWithPath: resourceFolderPath!).appendingPathComponent("login.json").path
        
        let fileExists = FileManager.default.fileExists(atPath: fullPath, isDirectory: nil)
        
        if (fileExists)
        {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: fullPath), options: .mappedIfSafe)
                let jsonObj = JSON(data: data)
                if (jsonObj != JSON.null)
                {
                    print("jsonData:\(jsonObj)")
                    
                    let dict = jsonObj["d"].dictionaryValue
                    
                    let arr = dict["results"]?.array
                    
                    for dic in arr!
                    {
                        resultArray.append(LoginModel.init(json: dic)!)
                    }
                }
                else
                {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error
            {
                print(error.localizedDescription)
            }
        }
        else
        {
            print("Invalid filename/path.")
            
        }
        return resultArray
    }

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    func resetField() {
        usernameField.text = ""
        passwordField.text = ""
    }
    
    @IBAction func LoginButtonPressed(_ sender: AnyObject) {
        fetchUsers()
    }
    
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title:title,message:message, preferredStyle:UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

