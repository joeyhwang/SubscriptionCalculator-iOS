//
//  ActiveTableViewCell.swift
//  SubscriptionCalculator
//
//  Created by Joey Hwang on 12/18/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import CoreData

class ActiveTableViewCell: UITableViewCell {

    @IBOutlet weak var subscriptionImageView: UIImageView!
    
    @IBOutlet weak var subscriptionName: UILabel!
    
   // @IBOutlet weak var subscriptionStartDate: UILabel!
    
    @IBOutlet weak var subscriptionCost: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    
    func configure(currentSubscription: NSManagedObject) {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        
        _ = currentSubscription.value(forKey: Keys.startDate) as! Date
        let image = UIImage(named: currentSubscription.value(forKey: Keys.picture) as! String)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        let cycle = currentSubscription.value(forKey: Keys.cycle) as! String
        let price = currentSubscription.value(forKey: Keys.price) as! Double
        let formmattedCurrency = currencyFormatter.string(from: NSNumber(value: price))
        
        subscriptionCost.text =  formmattedCurrency! + " " + cycle
        subscriptionName.text = currentSubscription.value(forKey: Keys.name) as? String
        subscriptionImageView.image = image
        
        //subscriptionStartDate.text = dateFormatter.string(from: date)
        
        subscriptionCost.adjustsFontSizeToFitWidth = true
    
        
        subscriptionName.adjustsFontSizeToFitWidth = true
    }
}
