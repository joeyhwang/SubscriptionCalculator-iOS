//
//  ActiveTableViewController.swift
//  SubscriptionCalculator
//
//  Created by Joey Hwang on 12/16/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import CoreData
class ActiveTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var container: NSPersistentContainer!
    var fetchedResultsController: NSFetchedResultsController<CurrentSubscription>!
    var subs : Subscriptions?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Active"
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.title = "Deactivate"
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        print("active table view will appear")
        initializeFetchedResultsController()
        tableView.reloadData()
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing,animated:animated)
        if(self.isEditing)
        {
             self.navigationItem.rightBarButtonItem?.title = "Cancel"
        }else
        {
             self.navigationItem.rightBarButtonItem?.title = "Deactivate"
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
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CurrentSubscription")
        let sort = NSSortDescriptor(key: Keys.name, ascending: true )
        request.sortDescriptors = [sort]
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        container = appDelegate.persistentContainer
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil) as? NSFetchedResultsController<CurrentSubscription>
        fetchedResultsController.delegate = self
        
        do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
    }
    
    // MARK: Search Bar Methods
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        fetchedResultsController.fetchRequest.predicate = nil
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch let err {
            print(err)
        }
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        var predicate: NSPredicate?
        if searchText.count > 0 {
            predicate = NSPredicate(format: "(name contains[cd] %@) || (price contains[cd] %@) || (cycle contains[cd] %@) || (type contains[cd] %@)", searchText, searchText, searchText, searchText)
        } else {
            predicate = nil
        }
        
        fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch let err {
            print(err)
        }

    }
    

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSubscription = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveTableViewCell", for: indexPath) as! ActiveTableViewCell
        
        cell.configure(currentSubscription: currentSubscription)

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSubscription = fetchedResultsController.object(at: indexPath)
        subs = Subscriptions(name: currentSubscription.name!, icon: currentSubscription.picture!, type: currentSubscription.type!)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Subscriptions", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddSubscriptionViewController") as! AddSubscriptionViewController
        vc.subscription = subs
        self.show(vc, sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentSubscription = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(currentSubscription)
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
            }

            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "InactiveSubscription", in: managedContext)!
            let inactiveSubscriptionEntity = NSManagedObject(entity: entity, insertInto: managedContext)
            
            inactiveSubscriptionEntity.setValue(currentSubscription.name, forKey: Keys.name)
            inactiveSubscriptionEntity.setValue(currentSubscription.cycle, forKey: Keys.cycle)
            inactiveSubscriptionEntity.setValue(currentSubscription.startDate, forKey: Keys.startDate)
            inactiveSubscriptionEntity.setValue(Date(), forKey: Keys.endDate)
            inactiveSubscriptionEntity.setValue(currentSubscription.price, forKey: Keys.price)
            inactiveSubscriptionEntity.setValue(currentSubscription.picture!, forKey: Keys.picture)
            inactiveSubscriptionEntity.setValue(currentSubscription.type, forKey: Keys.type)
            inactiveSubscriptionEntity.setValue(currentSubscription.monthsFree, forKey: Keys.monthsFree)
            saveContext()
        }
    }

    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            
            tableView.deleteRows(at: [indexPath!], with: .automatic)

        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Deactivate"
    }
    
}
