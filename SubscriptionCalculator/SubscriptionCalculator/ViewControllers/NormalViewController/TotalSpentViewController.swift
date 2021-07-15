//
//  TotalSpentViewController.swift
//  SubscriptionCalculator
//
//  Created by Joey Hwang on 12/14/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import Charts
import CoreData
class TotalSpentViewController: UIViewController {
    
    @IBOutlet weak var activeSubscriptionCount: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var inactiveSubscriptionCount: UILabel!
    @IBOutlet weak var averagePrice: UILabel!
    @IBOutlet weak var totalSpentPriceLabel: UILabel!
    @IBOutlet weak var timePeriodPriceLabel: UILabel!
    
    @IBOutlet weak var currentSubsTextLabel: UILabel!
    @IBOutlet weak var pastSubsTextLabel: UILabel!
    
    @IBOutlet weak var averageTextLabel: UILabel!
    @IBOutlet weak var timePeriodTextLabel: UILabel!
    @IBOutlet weak var totalSpentTextLabel: UILabel!
    
    var totalSpent: Int = 0
    var yearly: Double = 0
    var avg: Double = 0
    var subscriptionCount: Double = 0
    var typesCost : [String: Double] = [Type.dating : 0, Type.games: 0,Type.streaming : 0, Type.music: 0, Type.webServices: 0, Type.other: 0]
    //
    var subscriptionTypes : [String: Double] = [Type.dating : 0, Type.games: 0,Type.streaming : 0, Type.music: 0, Type.webServices: 0, Type.other: 0]
    
    var activeTimePeriodDict : [String: Int] = ["Monthly": 0, "Yearly": 0, "Weekly" : 0]
    var inactiveTimePeriodDict : [String: Int] = ["Monthly": 0, "Yearly": 0, "Weekly" : 0]
    var timePeriodType: String = ""
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var typePieChart: PieChartView!
    
    var numberOfTypesInChart = [PieChartDataEntry]()
    var inactiveSubscriptionList: [InactiveSubscription] = []
    var currentSubscriptionList: [CurrentSubscription] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        averageTextLabel.adjustsFontSizeToFitWidth = true
        segmentedControl.selectedSegmentIndex = defaults.integer(forKey: Keys.timePeriod)
        
        typePieChart.entryLabelColor = .white
        typePieChart.entryLabelFont = .systemFont(ofSize: 14, weight: .semibold)
        typePieChart.backgroundColor = UIColor(rgb: 0x272727)
        
        typePieChart.chartDescription?.text = ""
        typePieChart.noDataTextColor = UIColor(rgb: 0x272727)
        typePieChart.holeColor = UIColor(rgb: 0x272727)
        
        
        let legend = typePieChart.legend
        legend.textColor = .white
        legend.xEntrySpace = 7
        legend.yEntrySpace = 0
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //reset variables
        avg = 0
        yearly = 0
        totalSpent = 0
        subscriptionCount = 0
        typesCost = [Type.dating : 0, Type.games: 0,Type.streaming : 0, Type.music: 0, Type.webServices: 0, Type.other: 0]
        subscriptionTypes = [Type.dating : 0, Type.games: 0,Type.streaming : 0, Type.music: 0, Type.webServices: 0, Type.other: 0]
        activeTimePeriodDict = ["Monthly": 0, "Yearly": 0, "Weekly" : 0]
        inactiveTimePeriodDict = ["Monthly": 0, "Yearly": 0, "Weekly" : 0]
        
        print("disappear " + String(avg))
        
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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CurrentSubscription")
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "InactiveSubscription")

 
        
        //3
        do {
            currentSubscriptionList = try managedContext.fetch(fetchRequest) as! [CurrentSubscription]
            inactiveSubscriptionList = try managedContext.fetch(fetchRequest2) as! [InactiveSubscription]
            let timePeriod = defaults.integer(forKey: Keys.timePeriod)
            switch timePeriod {
                case 0:
                    timePeriodType = "Weekly"
                case 1:
                    timePeriodType = "Monthly"
                case 2:
                    timePeriodType = "Yearly"
                default:
                    print("")
            }
            
            calculateSubscription(currentSubscriptionList: currentSubscriptionList, inactiveSubscriptionList: inactiveSubscriptionList)
            
            var totalCost: Double = 0
        
            // calculate total spent so far
            for (_, cost) in typesCost {
                totalCost += cost
            }
            
            
            let formattedTotal = currencyFormatter.string(from: NSNumber(value: totalCost))
            totalSpentPriceLabel.text = formattedTotal!
   
            
            switch timePeriod {
            case 0:
        
                let formattedAvg = currencyFormatter.string(from: NSNumber(value: avg/52))
                let formattedYearly = currencyFormatter.string(from: NSNumber(value: yearly/52))
                averageTextLabel.text = "Average Sub Cost Weekly: "
                averagePrice.text = formattedAvg!
                timePeriodTextLabel.text = "Weekly Price: "
                timePeriodPriceLabel.text =  formattedYearly!
                
                //week
            case 1:
                let formattedAvg = currencyFormatter.string(from: NSNumber(value: avg/12))
                let formattedYearly = currencyFormatter.string(from: NSNumber(value: yearly/12))
                averageTextLabel.text = "Average Monthly Sub Cost Monthly: "
                averagePrice.text = formattedAvg!
                timePeriodTextLabel.text = "Monthly Price: "
                timePeriodPriceLabel.text = formattedYearly!
                //month
                
            case 2:
                let formattedAvg = currencyFormatter.string(from: NSNumber(value: avg))
                let formattedYearly = currencyFormatter.string(from: NSNumber(value: yearly))
                averageTextLabel.text = "Average Sub Cost Yearly: "
                averagePrice.text = formattedAvg!
                timePeriodTextLabel.text = "Yearly Price: "
                timePeriodPriceLabel.text = formattedYearly!
                //year
                
            default:
                print("")
            }
            
            updateChartData()
            //bar chart
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            }
        }

    private func calculateSubscription(currentSubscriptionList : [CurrentSubscription], inactiveSubscriptionList: [InactiveSubscription] ) {
        for a in currentSubscriptionList {
            let price = a.value(forKey: Keys.price) as! Double
            let cycle = a.value(forKey: Keys.cycle) as! String
            let startDate = a.value(forKey: Keys.startDate) as! Date
            let monthsFree = a.value(forKey: Keys.monthsFree) as! Int
            let type = a.value(forKey: Keys.type) as! String
            
            for (k,_) in activeTimePeriodDict {
                if (cycle == k) {
                    activeTimePeriodDict[k]! += 1
                }
            }
            
            calculateTotalSpent(startDate: startDate, monthsFree: monthsFree, cycle: cycle, type: type, price: price)
            
            subscriptionTypes[type]! += 1
            let yearlyPrice = convertToYearly(cycle: cycle, price: price)
            yearly += yearlyPrice
        }
        
        for a in inactiveSubscriptionList {
            let price = a.value(forKey: Keys.price) as! Double
            let cycle = a.value(forKey: Keys.cycle) as! String
            let startDate = a.value(forKey: Keys.startDate) as! Date
            let endDate = a.value(forKey: Keys.endDate) as! Date
            let monthsFree = a.value(forKey: Keys.monthsFree) as! Int
            let type = a.value(forKey: Keys.type) as! String
            
            for (k,_) in inactiveTimePeriodDict {
                if (cycle == k) {
                    inactiveTimePeriodDict[k]! += 1
                }
            }
            
            calculateTotalSpent(startDate: startDate, monthsFree: monthsFree, cycle: cycle, type: type, price: price, endDate: endDate)
            
            subscriptionTypes[type]! += 1
            let yearlyPrice = convertToYearly(cycle: cycle, price: price)
            yearly += yearlyPrice
            
        }
        print(timePeriodType)
        activeSubscriptionCount.text = String(activeTimePeriodDict[timePeriodType]!) + "/" + String(currentSubscriptionList.count)
        inactiveSubscriptionCount.text = String(inactiveTimePeriodDict[timePeriodType]!) + "/" + String(inactiveSubscriptionList.count)
        currentSubsTextLabel.text = timePeriodType + " Active / Total Active"
        pastSubsTextLabel.text = timePeriodType + " Inactive / Total Inactive"
        subscriptionCount += Double(currentSubscriptionList.count) + Double(inactiveSubscriptionList.count)
        if subscriptionCount == 0 {
            avg = 0
        } else {
            avg += yearly / subscriptionCount
        }
        
        
    }
    
    
    
    private func convertToYearly(cycle: String, price: Double) -> Double {
        switch cycle {
        case "Monthly":
            return 12 * price
        case "Yearly":
            return price
        case "Weekly":
            return 52 * price
        default:
            return 0
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
                    typesCost[type]! += Double(weekDifference) * price
                }
            }
            
        case "Monthly":
            if let month = monthComponent.month {
                let monthDifference = month - monthsFree
                if (monthDifference > 0) {
                    typesCost[type]! += Double(monthDifference) * price
                }
            }
            
        case "Yearly":
            if let year = yearComponent.year {
                typesCost[type]! += Double(year) * price
            }
            
        default:
            print("")
        }
    }

    @IBAction func indexChanged(_ sender: Any) {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        
        
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            let formattedAvg = currencyFormatter.string(from: NSNumber(value: avg/52))
            let formattedYearly = currencyFormatter.string(from: NSNumber(value: yearly/52))
            
            averageTextLabel.text = "Average Sub Cost Weekly: "
            timePeriodTextLabel.text = "Weekly Price: "
            timePeriodType = "Weekly"
            averagePrice.text =  formattedAvg!
            timePeriodPriceLabel.text = formattedYearly!
            defaults.set(0, forKey: Keys.timePeriod)
            activeSubscriptionCount.text = String(activeTimePeriodDict[timePeriodType]!) + "/" + String(currentSubscriptionList.count)
            inactiveSubscriptionCount.text = String(inactiveTimePeriodDict[timePeriodType]!) + "/" + String(inactiveSubscriptionList.count)
            currentSubsTextLabel.text = timePeriodType + " Active / Total Active"
            pastSubsTextLabel.text = timePeriodType + " Inactive / Total Inactive"
            //week
        case 1:
            //month
            let formattedAvg = currencyFormatter.string(from: NSNumber(value: avg/12))
            let formattedYearly = currencyFormatter.string(from: NSNumber(value: yearly/12))
            
            averageTextLabel.text = "Average Sub Cost Monthly: "
            timePeriodTextLabel.text = "Monthly Price: "
            averagePrice.text =  formattedAvg!
            timePeriodPriceLabel.text =  formattedYearly!
            defaults.set(1, forKey: Keys.timePeriod)
            timePeriodType = "Monthly"
            activeSubscriptionCount.text = String(activeTimePeriodDict[timePeriodType]!) + "/" + String(currentSubscriptionList.count)
            inactiveSubscriptionCount.text = String(inactiveTimePeriodDict[timePeriodType]!) + "/" + String(inactiveSubscriptionList.count)
            currentSubsTextLabel.text = timePeriodType + " Active / Total Active"
            pastSubsTextLabel.text = timePeriodType + " Inactive / Total Inactive"
            
        case 2:
            //year
            let formattedAvg = currencyFormatter.string(from: NSNumber(value: avg))
            let formattedYearly = currencyFormatter.string(from: NSNumber(value: yearly))
            
            averageTextLabel.text = "Average Sub Cost Yearly: "
            timePeriodTextLabel.text = "Yearly Price: "
            averagePrice.text = formattedAvg!
            timePeriodPriceLabel.text = formattedYearly!
            timePeriodType = "Yearly"
            defaults.set(2, forKey: Keys.timePeriod)
            activeSubscriptionCount.text = String(activeTimePeriodDict[timePeriodType]!) + "/" + String(currentSubscriptionList.count)
            inactiveSubscriptionCount.text = String(inactiveTimePeriodDict[timePeriodType]!) + "/" + String(inactiveSubscriptionList.count)
            currentSubsTextLabel.text = timePeriodType + " Active / Total Active"
            pastSubsTextLabel.text = timePeriodType + " Inactive / Total Inactive"
        default:
            print("")
        }
    }
    
    private func updateChartData() {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        
        var a = [PieChartDataEntry]()
        var total_spent: Double = 0
        for (type, cost) in typesCost {
            if (cost > 0) {
                print(type)
                let c = Double(round(100*cost)/100)
                total_spent += c
                a.append(PieChartDataEntry(value: c, label: type))
            }
        }
        
        
        let chartDataSet = PieChartDataSet(entries: a, label: "")
        chartDataSet.sliceSpace = 2
        chartDataSet.valueLinePart1OffsetPercentage = 0.8
        chartDataSet.valueLinePart1Length = 0.6
        chartDataSet.valueLinePart2Length = 0.3
        chartDataSet.valueLineColor = .white
        //set.xValuePosition = .outsideSlice
        chartDataSet.yValuePosition = .outsideSlice
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        chartData.setValueFont(.systemFont(ofSize: 16, weight: .bold))
        chartData.setValueTextColor(.white)
        
        let formattedTotal = currencyFormatter.string(from: NSNumber(value: total_spent))
        
        typePieChart.centerText = formattedTotal!
        
        let colors : [UIColor] = [UIColor(rgb: 0x003f5c), UIColor(rgb: 0x444e86), UIColor(rgb: 0x955196), UIColor(rgb: 0xdd5182), UIColor(rgb:0xff6e54), UIColor(rgb: 0xffa600)]
        chartDataSet.colors = colors
        typePieChart.data = chartData
        typePieChart.notifyDataSetChanged()
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
