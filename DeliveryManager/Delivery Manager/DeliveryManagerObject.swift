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
    struct JsonDeliveryKey{
        static let kPostcode = "0000"
        static let kVbeln = "0000000000"
        static let kStreet = "Street"
        static let kCity = "City"
        static let kKunnr = "00"
        static let kDate = "Date"
        static let kName = "Name"
    }
    var postcode:String!
    var vbeln:String!
    var street:String!
    var city:String!
    var kunnr:String!
    var date:String!
    var name:String!


    public init?(json: JSON?)
    {
        guard let json = json else
        {
            return nil
        }
    
    
        if let postcode =  json[JsonDeliveryKey.kPostcode ].string
        {
            self.postcode = postcode
        }
    
    
        if let vbeln =  json[JsonDeliveryKey.kVbeln].string
        {
            self.vbeln = vbeln
        }
        
        if let street = json[JsonDeliveryKey.kStreet].string
        {
            self.street = street
        }
        
        if let city =  json[JsonDeliveryKey.kCity].string
        {
            self.city = city
        }
        
        if let kunnr =  json[JsonDeliveryKey.kKunnr].string
        {
            self.kunnr = kunnr
        }
        
        if let date =  json[JsonDeliveryKey.kDate].string
        {
            self.date = date
        }
        
        if let name =  json[JsonDeliveryKey.kName].string
        {
            self.name = name
        }
    
    }
}
