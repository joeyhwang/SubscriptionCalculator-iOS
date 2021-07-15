//
//  SubscriptionCollectionViewCell.swift
//  SubscriptionCalculator
//
//  Created by Joey Hwang on 12/15/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit

class SubscriptionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var subscriptionIcon: UIImageView!
    
    var subscription: Subscriptions? = nil {
        didSet {
            if let subscription = subscription{
                let img = UIImage(named: subscription.icon)
                subscriptionIcon.image = img
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
