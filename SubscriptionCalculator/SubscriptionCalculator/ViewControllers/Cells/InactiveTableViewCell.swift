//
//  InactiveTableViewCell.swift
//  SubscriptionCalculator
//
//  Created by Joey Hwang on 12/18/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import CoreData
class InactiveTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subscriptionImageView: UIImageView!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var startDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(inactiveSubscription: NSManagedObject) {
        let startDate = inactiveSubscription.value(forKey: Keys.startDate) as! Date
        let endDate = inactiveSubscription.value(forKey: Keys.endDate) as! Date
        let image = UIImage(named: inactiveSubscription.value(forKey: Keys.picture) as! String)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        nameLabel.text = inactiveSubscription.value(forKey: Keys.name) as? String
        subscriptionImageView.image = image
        self.startDate.text = dateFormatter.string(from: startDate)
        self.endDate.text = dateFormatter.string(from: endDate)
        
        //subscriptionStartDate.text = dateFormatter.string(from: date)
        
    
        
        nameLabel.adjustsFontSizeToFitWidth = true
    }

}
