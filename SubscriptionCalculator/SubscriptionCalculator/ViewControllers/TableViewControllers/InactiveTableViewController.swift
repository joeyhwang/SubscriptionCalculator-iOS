//
//  InactiveTableViewController.swift
//  SubscriptionCalculator
//
//  Created by Joey Hwang on 12/18/19.
//  Copyright © 2019 Joey Hwang. All rights reserved.
//

import UIKit
import CoreData
class InactiveTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var container: NSPersistentContainer!
       var fetchedResultsController: NSFetchedResultsController<InactiveSubscription>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inactive"
        searchBar.delegate = self
        searchBar.showsCancelButton = true
    }

    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        print("active table view will appear")
        initializeFetchedResultsController()
        tableView.reloadData()
        self.navigationItem.rightBarButtonItem = self.editButtonItem

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
        let request = NSFetchRequest<NSManagedObject>(entityName: "InactiveSubscription")
        let sort = NSSortDescriptor(key: Keys.name, ascending: true )
        request.sortDescriptors = [sort]
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        container = appDelegate.persistentContainer
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil) as? NSFetchedResultsController<InactiveSubscription>
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
            predicate = NSPredicate(format: "(name contains[cd] %@) || (price contains[cd] %@) || (cycle contains[cd] %@) ", searchText, searchText, searchText)
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
        let inactiveSubscription = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InactiveTableViewCell", for: indexPath) as! InactiveTableViewCell
        
        cell.configure(inactiveSubscription: inactiveSubscription)

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSubscription = fetchedResultsController.object(at: indexPath)
        let storyboard: UIStoryboard = UIStoryboard(name: "InactiveStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InactiveViewController") as! InactiveViewController
        vc.inactiveSubscription = currentSubscription
        self.show(vc, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentSubscription = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(currentSubscription)
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
    
    
}
