//
//  SubscriptionsViewController.swift
//  SubscriptionCalculator
//
//  Created by Joey Hwang on 12/14/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit

class SubscriptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var categories = ["Streaming", "Music", "Games", "Web Services", "Other"]
    @IBOutlet weak var subscriptionTable: UITableView!
    struct Item {
      var imageName: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        title = "Subscriptions"
        subscriptionTable.rowHeight = 120
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let subscriptionCollectionViewCell = sender as? SubscriptionCollectionViewCell,
            let addSubscriptionPage = segue.destination as? AddSubscriptionViewController {
            
            addSubscriptionPage.subscription = subscriptionCollectionViewCell.subscription
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return catalog.genres.count
    }
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return catalog.genres[section].name
    }
    */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 20, y: 0, width: tableView.frame.width, height: 40))
        
        headerView.backgroundColor = UIColor.clear
        let label = UILabel()
        label.frame = CGRect.init(x: 15, y: 8, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        label.text = catalog.genres[section].name
        
        label.font = UIFont(name:"Avenir Next-Bold", size: 19) // my custom font
        label.textColor = .white
        
        //label.backgroundColor = UIColor.gray
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CategoryTableViewCell
        cell.genre = catalog.genres[indexPath.section]
        return cell
    }

    
}
