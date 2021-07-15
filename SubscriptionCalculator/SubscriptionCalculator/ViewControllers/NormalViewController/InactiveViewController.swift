//
//  InactiveViewController.swift
//  SubscriptionCalculator
//
//  Created by Joey Hwang on 12/23/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import CoreData

class InactiveViewController: UIViewController {
    var subscription: Subscriptions? = nil
    var container: NSPersistentContainer!
    var inactiveSubscription: InactiveSubscription?
    var totalSpent: Double = 0
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cycleLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var monthsFreeLabel: UILabel!
    @IBOutlet weak var totalSpentLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let deleteBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(delete(sender:)))
        self.navigationItem.rightBarButtonItem = deleteBarButtonItem
        
    }
    
    @objc func delete(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: "", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: { action in
            self.container.viewContext.delete(self.inactiveSubscription!)
            self.saveContext()
            self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        

        // show the alert
        self.present(alert, animated: true, completion: nil)
        /*
        container.viewContext.delete(inactiveSubscription!)
        saveContext()
        navigationController?.popViewController(animated: true)
 */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        container = appDelegate.persistentContainer
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        
        
        nameLabel.text = inactiveSubscription?.name
        let image = UIImage(named: inactiveSubscription!.picture!)
        iconImageView.image = image
        
        let startDate = inactiveSubscription!.startDate!
        let endDate = inactiveSubscription!.endDate!
        let cycle = inactiveSubscription!.cycle!
        let price = inactiveSubscription!.price
        let type = inactiveSubscription!.type!
        let monthsFree = inactiveSubscription!.monthsFree
        let formattedPrice = currencyFormatter.string(from: NSNumber(value: price))
        priceLabel.text = formattedPrice
        startDateLabel.text = dateFormatter.string(from: startDate)
        endDateLabel.text = dateFormatter.string(from: endDate)
        cycleLabel.text = cycle
        monthsFreeLabel.text = String(inactiveSubscription!.monthsFree)
        
        calculateTotalSpent(startDate: startDate, monthsFree: Int(monthsFree), cycle: cycle, type: type, price: price, endDate: endDate)
        totalSpentLabel.text = "Total Spent: " + currencyFormatter.string(from: NSNumber(value: totalSpent))!
        
    }
    
    private func calculateTotalSpent(startDate: Date, monthsFree: Int, cycle: String, type: String, price: Double, endDate: Date) {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: startDate)
        let date2 = calendar.startOfDay(for: endDate)
        let dayComponent = calendar.dateComponents([.day], from: date1, to: date2)
        let monthComponent = calendar.dateComponents([.month], from: date1, to: date2)
        let yearComponent = calendar.dateComponents([.year], from: date1, to: date2)
        
        switch cycle {
        case "Weekly":
            if let day = dayComponent.day {
                
                let weeks = day / 7
                let weeksFree = 4 * monthsFree
                let weekDifference = weeks - weeksFree
                print(day)
                print(weeks)
                print(weekDifference)
                if (weekDifference > 0) {
                    totalSpent += Double(weekDifference) * price
                }
            }
            
        case "Monthly":
            if let month = monthComponent.month {
                let monthDifference = month - monthsFree
                if (monthDifference > 0) {
                    totalSpent += Double(monthDifference) * price
                }
            }
            
        case "Yearly":
            if let year = yearComponent.year {
                totalSpent += Double(year) * price
            }
            
        default:
            print("")
        }
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    
    
}
