//
//  CustomTableViewCell.swift
//  Delivery Manager
//
//  Created by Sohan Chunduru on 6/28/17.
//  Copyright © 2017 Sohan Chunduru. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var DeliveryNumber: UILabel!
    @IBOutlet weak var CustomerName: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var DeliveryDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
