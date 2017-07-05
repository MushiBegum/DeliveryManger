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



class MapViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, GMSMapViewDelegate{
    private var deliveryList: [DeliveryManagerObject] = [DeliveryManagerObject]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var aMapView: GMSMapView!
    
    
    @IBOutlet weak var customInfoWindow : UIView?
    @IBOutlet weak var descriptionLabel : UILabel?
    @IBOutlet weak var priorityLabel : UILabel?
    @IBOutlet weak var workCenterLabel : UILabel?
    @IBOutlet weak var plantLabel : UILabel?
    
    
    typealias DirectionsCompletionHandler = (GoogleResult<GMSPath>) -> Void
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var locationManager = CLLocationManager()
    
    var selectedMarker : GMSMarker?
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var selectedObj : DeliveryManagerObject!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Deliveries"
        fetchDeliveryData()
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
        
    }
    private func fetchDeliveryData(){
        let deliveryResponseObjs = fetchDeliveryList()
        deliveryList =  deliveryResponseObjs.sorted(by: { $0.DelNo > $1.DelNo})
        renderAlltheMarkers()
    }
    
    //Table View- Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DeliveryCell", for: indexPath ) as! CustomTableViewCell
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 127
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.showMap(delivery: deliveryList[indexPath.row])
    }
    

    
    
    
    // MARK: - Private Methods
    
    private func initializeVariables()
    {
        aMapView?.mapType = .normal
        
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.startUpdatingLocation()
        self.tableView.reloadData()
    }
    
    func showMap(delivery : DeliveryManagerObject?)
    {
        self.aMapView?.clear()
        self.selectedMarker = nil
        
        if (delivery != nil)
        {
            self.getCamera()
            
            self.loadLocationFromAddressString(delivery: delivery!, selectmarker: true)
        }
    }
    
    // MARK: - SHOW MARKERS
    func renderAlltheMarkers()
    {
        getCamera()
        
        aMapView?.delegate = self
        
        for i in (0..<self.deliveryList.count)
        {
            let obj = self.deliveryList[i]
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
    //MARK: -- Button action methods
    
    @IBAction func onClickOfCurentLocation(sender : UIButton)
    {
        self.markCurrentLocation()
    }
    
    func markCurrentLocation()
    {
        if self.selectedMarker == nil
        {
            self.aMapView?.clear()
        }
        
        let position = self.locationManager.location?.coordinate
        
        let cMarker = GMSMarker.init(position: position!)
        cMarker.appearAnimation = .pop
        
        cMarker.isFlat = true
        cMarker.isTappable = true
        let image = UIImage(named: "MARKER_CL")
        cMarker.icon = image
        cMarker.infoWindowAnchor = CGPoint(x: 0.95, y: -0.4)
        cMarker.map = self.aMapView
        
        cMarker.isTappable = false
    }
    
    @IBAction func onClickOfAllLocation(sender : UIButton)
    {
        self.renderAlltheMarkers()
    }
    
    @IBAction func onClickRoute(sender : UIButton)
    {
        self.drawPolyLine()
    }
    
    //MARK: - GMSMapViewDelegate methods
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker)
    {
        self.performSegue(withIdentifier: "segueToOrders", sender: self)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?
    {
        let sydney = GMSCameraPosition.camera(withLatitude: marker.position.latitude,
                                              longitude:  marker.position.longitude,
                                              zoom: 12)
        mapView.camera = sydney
        
        self.descriptionLabel?.text = marker.title
        self.priorityLabel?.text = marker.snippet
        
        for i in (0..<self.deliveryList.count)
        {
            let obj = self.deliveryList[i]
            
            if (marker.snippet == obj.DelNo)
            {
                self.selectedObj = obj
                
                self.descriptionLabel?.text = obj.CustName
                self.priorityLabel?.text = obj.DelDate
                
                self.workCenterLabel?.text = String(format: "Address: %@", obj.DelDesc)
                self.plantLabel?.text = String(format: "Delivery Number: %@", obj.DelNo)
            }
        }
        return self.customInfoWindow
    }
    
    
    
    //MARK: Draw PolyLine
    
    func drawPolyLine()
    {
        guard self.selectedMarker != nil else {
            return
        }
        
        self.getDirectionsFrom(mapView: self.aMapView!, marker: selectedMarker!){ result in
            
            switch result {
            case .Success(let path):
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeColor = UIColor(red:68.0/255.0, green: 94.0/255.0, blue: 117.0/255.0, alpha: 1)
                polyline.strokeWidth = 3.0
                polyline.map = self.aMapView
            case .Error(let error):
                print("Error: \(error)")
                
            }
        }

    
    }
    func getDirectionsFrom(mapView: GMSMapView, marker: GMSMarker, completion: @escaping DirectionsCompletionHandler) {
        
        guard let startLatitude = self.locationManager.location?.coordinate.latitude, let startLongitude = self.locationManager.location?.coordinate.longitude else {
            print("NO starting point of user")
            return
        }
        
        //        let startLatitude = self.locationManager.location?.coordinate.latitude
        //        let startLongitude = self.locationManager.location?.coordinate.longitude
        
        let startLocation = "\(startLatitude),\(startLongitude)"
        let endlocation = "\(marker.position.latitude),\(marker.position.longitude)"
        
        
        let urlString = "\(GoogleMapService.baseURL)origin=\(startLocation)&destination=\(endlocation)&sensor=true&key=\(GoogleMapService.directionApiKey)"
        
        if let url = URL(string: urlString) {
            
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (response) in
                
                if response.response?.statusCode == 200 {
                    
                    if let json = response.result.value as? [String: AnyObject], let status = json["status"] as? String {
                        
                        if status == "OK" {
                            
                            if let routes = json["routes"] as? [[String: AnyObject]],
                                let firstRoute = routes.first,
                                let polyline = firstRoute["overview_polyline"] as? [String: AnyObject],
                                let points = polyline["points"] as? String {
                                
                                if  let path = GMSPath.init(fromEncodedPath: points) {
                                    completion(.Success(path))
                                } else {
                                    completion(.Error(.invalidPath))
                                }
                            } else {
                                completion(.Error(.pointsNotFoundedError))
                            }
                        } else {
                            completion(.Error(.statusFailure))
                        }
                    } else {
                        completion(.Error(.invalidJSON))
                    }
                } else {
                    completion(.Error(.statusCodeNot200))
                }
            })
        } else {
            completion(.Error(.invalidURL))
        }
    }
    
    
    
    //MARK: Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.locationManager = manager
    }
    
    //MARK: Alert
    public func errorAlertView(error: NSError) {
        
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    

}
