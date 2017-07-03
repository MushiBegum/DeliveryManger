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
import GooglePlaces
import CoreLocation
import Alamofire

enum GoogleResult<T>{
    case Success(T)
    case Error(GoogleError)
}

enum GoogleError: Error {
    case invalidURL
    case invalidJSON
    case statusCodeNot200
    case statusFailure
    case pointsNotFoundedError
    case invalidPath
}

struct GoogleMapService
{
    static let baseURL = "https://maps.googleapis.com/maps/api/directions/json?"
    static let directionApiKey = "AIzaSyDNZT7mefFUm0PHJ7Ob10Cm0Nl9L5wkT8o"
}



class MapViewController: UIViewController, UITableViewDelegate, GMSMapViewDelegate{
    private var deliveryList: [DeliveryManagerObject] = [DeliveryManagerObject]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var aMapView: GMSMapView!
    
    
    
    typealias DirectionsCompletionHandler = (GoogleResult<GMSPath>) -> Void
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    
    var deliveryListArray = [DeliveryManagerObject]()
    
    var locationManager = CLLocationManager()
    
    var selectedMarker : GMSMarker?
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var selectedObj : DeliveryManagerObject!
    
    
    
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deliveryListArray = fetchDeliveryList()
        
        //Printing the data array
        for deliveryObj in deliveryListArray {
            print(deliveryObj.DelNo)
            print(deliveryObj.description)
            print(deliveryObj.DelDate)
            
        }
        
        
        renderAlltheMarkers()
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.distanceFilter = 50
            locationManager.startUpdatingLocation()
            locationManager.delegate = self as? CLLocationManagerDelegate
        }
        
        initializeVariables()
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func initializeVariables()
    {
        aMapView?.mapType = .normal
        
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.startUpdatingLocation()
    }
    
    
    
    // MARK: - SHOW MARKERS
    func renderAlltheMarkers()
    {
        getCamera()
        
        
        aMapView?.delegate = self
        
        for i in (0..<self.deliveryListArray.count)
        {
            let obj = self.deliveryListArray[i]
            loadLocationFromAddressString(delivery: obj, selectmarker: false)
            
            
        }
    }
    
    
        // MARK: - SHOW MARKERS
        
         func getCamera()
        {
            aMapView?.clear()
            
            selectedMarker = nil
            
            let camera = GMSCameraPosition.camera(withLatitude: -33.865143, longitude: 151.209900, zoom: 14)
            aMapView?.isMyLocationEnabled = true
            aMapView?.camera = camera
        }
        
         private func placeMarker(lat: CLLocationDegrees, lng : CLLocationDegrees) -> GMSMarker
        {
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
            let marker = GMSMarker.init(position: position)
            marker.appearAnimation = .pop
            
            marker.isFlat = true
            marker.isTappable = true
            marker.icon = UIImage(named: "MARKER")
            marker.infoWindowAnchor = CGPoint(x: 0.95, y: -0.4)
            marker.map = aMapView
            
            return marker
        }
        
        
        //MARK: - Reverse GeoCoding
        func loadLocationFromAddressString(delivery: DeliveryManagerObject, selectmarker: Bool)
        {
           
            
            let esc_addr = delivery.DelDesc.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            let req = String(format: "http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr!)
            
            
            performGet(urlString: req, headers: nil){ response, error, code in
                //  debugPrint(response!)
                
                let lat = response?["results"][0]["geometry"]["location"]["lat"].doubleValue
                let lon = response?["results"][0]["geometry"]["location"]["lng"].doubleValue
                
                let marker = self.placeMarker(lat: CLLocationDegrees(lat!), lng: CLLocationDegrees(lon!))
                
                marker.title = delivery.CustName
                marker.snippet = delivery.DelNo
                
                if selectmarker == true
                {
                    self.aMapView?.selectedMarker = marker
                    self.selectedMarker = marker
                }
            }
        }
         func performGet(urlString: String, headers: [String : String]?, completionHandler: @escaping (JSON?, NSError?, NSInteger?) -> ())
        {
            Alamofire.request(urlString, method: .get, parameters: ["":""], encoding: URLEncoding.default, headers: headers).responseJSON{
                response in // 1
                
                switch response.result
                {
                case .success(let value):
                    
                    let statusCode = (response.response?.statusCode)!
                    completionHandler(JSON(value), nil, statusCode)
                    
                case .failure(let error):
                    
                    let statusCode = response.response?.statusCode
                    completionHandler(nil, error as NSError?, statusCode)
                }
            }
        }



    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveryList.count
    }
    
    private func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"customCell", for: indexPath ) as! CustomTableViewCell
//        deliveryList = fetchDeliveryList()
        let delivery = deliveryList[indexPath.row]
        
        cell.CustomerName.text = delivery.CustName
        cell.DeliveryNumber.text = delivery.DelNo
        cell.DeliveryDate.text = delivery.DelDate
        cell.Description.text = delivery.city
        cell.Description.text = delivery.street
        cell.Description.text = delivery.DelDesc
        
        return cell
    }
    
}




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
