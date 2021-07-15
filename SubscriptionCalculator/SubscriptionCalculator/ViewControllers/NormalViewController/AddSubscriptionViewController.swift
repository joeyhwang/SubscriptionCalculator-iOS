//
//  AddSubscriptionViewController.swift
//  SubscriptionCalculator
//
//  Created by Joey Hwang on 12/15/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import CoreData

class AddSubscriptionViewController: UIViewController {

    
    var container: NSPersistentContainer!
    

    @IBOutlet weak var renewalLabel: UILabel!
    @IBOutlet weak var totalSpentLabel: UILabel!
    var subscription: Subscriptions? = nil
    @IBOutlet weak var subscriptionImage: UIImageView!
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var createActiveSubButton: UIButton!
    
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var billingCycleTextField: UITextField!
    
    private var datePicker: UIDatePicker?
    var selectedCycle: String?
    var subscriptionList: [NSManagedObject] = []
    let billingCycles = ["Weekly","Monthly","Yearly"]
    var totalSpent: Double = 0
    var update = false
    @IBOutlet weak var monthsFreeTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        createBillingCyclePicker()
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.maximumDate = Date()
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        startDateTextField.inputView = datePicker
        
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        priceTextField.placeholder = "Enter Price"
        startDateTextField.placeholder = "Enter Date"
        
        if let subscription = subscription {
            subscriptionLabel.text = subscription.name
            let icon = UIImage(named: subscription.icon)
            subscriptionImage.image = icon
        }
        
        renewalLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current

        //1
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        container = appDelegate.persistentContainer
        let managedContext =
        appDelegate.persistentContainer.viewContext

        //2
        let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "CurrentSubscription")

        //3
        do {
        subscriptionList = try managedContext.fetch(fetchRequest)
        print(subscriptionList.count)
        for a in subscriptionList {
            
            if (a.value(forKey: Keys.name) as? String  == subscription?.name) {

                createActiveSubButton.setTitle("Update Subscription", for : .normal)
                let price = a.value(forKey: Keys.price) as! Double
                let formattedPrice = currencyFormatter.string(from: NSNumber(value: price))
                let startDate = a.value(forKey: Keys.startDate) as! Date
                let cycle = a.value(forKey: Keys.cycle) as! String
                let monthsFree = a.value(forKey: Keys.monthsFree) as! Int
                let type = a.value(forKey: Keys.type) as! String
                priceTextField.text = formattedPrice
                startDateTextField.text = dateFormatter.string(from: startDate)
                billingCycleTextField.text = cycle
                monthsFreeTextField.text = String(monthsFree)
                update = true
                calculateTotalSpent(startDate: startDate, monthsFree: monthsFree, cycle: cycle, type: type, price: price)
                totalSpentLabel.text = "Total Spent: " + currencyFormatter.string(from: NSNumber(value: totalSpent))!
                //
                
            }
        }
        } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    private func calculateTotalSpent(startDate: Date, monthsFree: Int, cycle: String, type: String, price: Double, endDate: Date = Date()) {
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
    
    func calculateDaysToNextRenewal() {
        
    }
    
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        
        
        let array = text.compactMap({ Int(String($0)) })
        
        let num = Double(array.reduce(0, {($0 * 10) + $1})) / 100
        
        priceTextField.text = currencyFormatter.string(from: NSNumber(value: num))
        

    }
    
    lazy var currencyFormatter: NumberFormatter = {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter
    }()
    
    
    @IBAction func addSubscriptionButton(_ sender: UIButton) {
        if (subscriptionLabel.text != "" && priceTextField.text != "" && startDateTextField.text != "" && billingCycleTextField.text != "" && update == false) {
            save()
            let alert = UIAlertController(title: "Saved", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            createActiveSubButton.setTitle("Update Subscription", for : .normal)
            update = true
            
        } else if (subscriptionLabel.text != "" && priceTextField.text != "" && startDateTextField.text != "" && billingCycleTextField.text != "" && update == true) {
            //update the thing
            updateSubscription()
            let alert = UIAlertController(title: "Updated", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Incomplete Form", message: "All fields are required.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CurrentSubscription", in: managedContext)!
        let subscriptionEntity = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let date = dateFormatter.date(from: startDateTextField.text!)
        
        var priceText = priceTextField.text!
        priceText.remove(at: priceText.startIndex)
        priceText = priceText.replacingOccurrences(of: ",", with: "")
        
        subscriptionEntity.setValue(subscription?.name, forKeyPath: Keys.name)
        subscriptionEntity.setValue(subscription?.type, forKey: Keys.type)
        subscriptionEntity.setValue(subscription?.icon, forKeyPath: Keys.picture)
        subscriptionEntity.setValue(billingCycleTextField.text!, forKey: Keys.cycle)
        subscriptionEntity.setValue(Double(priceText), forKey: Keys.price)
        subscriptionEntity.setValue(date, forKeyPath: Keys.startDate)
        subscriptionEntity.setValue(Int(monthsFreeTextField.text!), forKey: Keys.monthsFree)
        
      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    func updateSubscription() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        for a in subscriptionList {
            if (a.value(forKey: Keys.name) as? String  == subscription?.name) {
                var priceText = priceTextField.text!
                priceText.remove(at: priceText.startIndex)
                priceText = priceText.replacingOccurrences(of: ",", with: "")
                
                
                a.setValue(billingCycleTextField.text!, forKey: Keys.cycle)
                a.setValue(Double(priceText), forKey: Keys.price)
                a.setValue(Int(monthsFreeTextField.text!), forKey: Keys.monthsFree)
                let dateFormatter = DateFormatter()
                       dateFormatter.dateFormat = "MM/dd/yy"
                       let date = dateFormatter.date(from: startDateTextField.text!)
                a.setValue(date, forKeyPath: Keys.startDate)
                
                do {
                  try managedContext.save()
                } catch let error as NSError {
                  print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        startDateTextField.text = dateFormatter.string(from: datePicker.date)
        startDateTextField.font = UIFont(name:"Avenir Next", size: 20)
        
    }
    
    func createBillingCyclePicker() {
        let cyclePicker = UIPickerView()
        cyclePicker.delegate = self
        billingCycleTextField.inputView = cyclePicker
        
    }
}


extension AddSubscriptionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return billingCycles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return billingCycles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCycle = billingCycles[row]
        billingCycleTextField.text = selectedCycle
    }
}


