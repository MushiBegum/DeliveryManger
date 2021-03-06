//
//  Order.swift
//  DeliveryManager
//
//  Created by Khasnobis, Pritha (US - Bengaluru) on 4/20/17.
//  Copyright © 2017 Khasnobis, Pritha (US - Bengaluru). All rights reserved.
//

import UIKit
import SwiftyJSON

public class LoginModel: NSObject
{
    struct jsonKey
    {
        static let kUsername = "Username"
        static let kPassword = "Password"
    
    }
    

    var userName : String!
    var password : String!
   
    
    public init?(json: JSON?)
    {
        guard let json = json else
        {
            return nil
        }
        
        
        if let userName =  json[jsonKey.kUsername ].string
        {
            self.userName = userName
        }
        
        
        if let password =  json[jsonKey.kPassword].string
        {
            self.password = password
        }

    }
}
