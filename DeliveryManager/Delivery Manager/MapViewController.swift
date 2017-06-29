//
//  MapViewController.swift
//
//
//  Created by Sohan Chunduru on 6/28/17.
//
//

import UIKit
import SwiftyJSON
import GoogleMaps


class MapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var deliveryList: [DeliveryManagerObject] = [DeliveryManagerObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"customCell", for: indexPath ) as! CustomTableViewCell
        deliveryList = fetchDeliveryList()
       // for delivery in deliveryList{
       //     cell.CustomerName = delivery.name
       // }
        let delivery = deliveryList[indexPath.row]
        
        cell.CustomerName.text = delivery.name
        return cell
    }
    
}
GMSS



//Fetch the json from json.file
public  func fetchDeliveryList() ->[DeliveryManagerObject]
{
    var resultArray = [DeliveryManagerObject]()
    let resourceFolderPath = Bundle.main.resourcePath
    let fullPath = URL(fileURLWithPath: resourceFolderPath!).appendingPathComponent("DeliveryList.json").path
    
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
                    resultArray.append(DeliveryManagerObject.init(json: dic)!)
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

func didReceiveMemoryWarning() {
    didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}




