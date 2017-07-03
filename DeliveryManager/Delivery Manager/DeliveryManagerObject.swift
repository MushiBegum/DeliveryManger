//
//  DeliveryManagerObject.swift
//  Delivery Manager
//
//  Created by Sohan Chunduru on 6/28/17.
//  Copyright © 2017 Sohan Chunduru. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


public class DeliveryManagerObject: NSObject
{
    struct apiKey
    {
        static let kDelNo = "Vbeln"
        static let kDelDate = "Lfdat"
        static let kCustName = "Name1"
        static let kDelDesc = "DelDesc"
        static let kStreet = "Street"
        static let kCity = "City1"
        static let kPin = "Kunnr"
    }
    
    var DelNo : String!
    var DelDate : String!
    var CustName : String!
    var DelDesc : String!
    var street : String!
    var city : String!
    var pin : String!
    
    //    var lat : Float = -33.8688
    //    var lng : Float = 151.2093
    
    public init?(json: JSON?)
    {
        guard let json = json else
        {
            return nil
        }
        
        if let DelNo =  json[apiKey.kDelNo].string
        {
            self.DelNo = DelNo
        }
        if let DelDate =  json[apiKey.kDelDate].string
        {
            let nDate = DelDate.components(separatedBy: "(")[1].components(separatedBy: ")")[0]
            
            let date = Date.init(timeIntervalSince1970: Double(nDate)! / 1000)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            self.DelDate = formatter.string(from: date)
        }
        if let CustName =  json[apiKey.kCustName].string
        {
            self.CustName = CustName
        }
        if let street =  json[apiKey.kStreet].string
        {
            self.street = street
        }
        if let city =  json[apiKey.kCity].string
        {
            self.city = city
        }
        if let pin =  json[apiKey.kPin].string
        {
            self.pin = pin
        }
        //        if let DelDesc =  json[apiKey.kDelDesc].string
        //        {
        self.DelDesc = self.street + ", " + self.city + " " + self.pin
        //        }
        
    }
    
    }

