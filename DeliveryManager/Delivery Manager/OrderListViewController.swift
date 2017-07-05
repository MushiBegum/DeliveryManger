//
//  OrderListViewController.swift
//  Delivery Manager
//
//  Created by Begum, Musheriya (US - Hyderabad) on 7/5/17.
//  Copyright © 2017 Sohan Chunduru. All rights reserved.
//

import UIKit

class OrderListViewController: UIViewController {

    @IBOutlet weak var footerVier : UIView!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var amtLbl: UILabel!
    
    @IBOutlet weak var delNoLbl: UILabel!
    @IBOutlet weak var custNameLbl: UILabel!
    @IBOutlet weak var addrLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
