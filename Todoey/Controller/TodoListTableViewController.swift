//
//  TodoListTableViewController.swift
//  Todoey
//
//  Created by VW MacAir on 8/1/2018.
//  Copyright © 2018年 viwil. All rights reserved.
//

import UIKit
import CoreData

class TodoListTableViewController: UITableViewController {

    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet {
            loadData()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (itemTextField) in
            itemTextField.placeholder = "type something"
            textField = itemTextField
        }
        
        let alertAction = UIAlertAction(title: "Click to add", style: .default) { (alertAction) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            self.saveData()
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)

        cell.textLabel?.text = itemArray[indexPath.row].title
        
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            saveData()
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } //else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //}
    }

    func saveData() {
        
        do {
            try context.save()
        } catch {
            print ("error when saving data \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
        } else {
            
            request.predicate = categoryPredicate
        }
        
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("error when loading data \(error)")
        }
        self.tableView.reloadData()
    }
}

//MARK: - Search Bar Section

extension TodoListTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS [cd] %@", searchBar.text!)

        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadData(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            
            loadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
//        else {
//
//            let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//            let predicate = NSPredicate(format: "title CONTAINS [cd] %@", searchBar.text!)
//
//            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//            loadData(with: request, predicate: predicate)
//        }
    }
}
