//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by VW MacAir on 16/1/2018.
//  Copyright © 2018年 viwil. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }

    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: nil, message: "Add a category", preferredStyle: .alert)
        
        alert.addTextField { (categoryTextField) in
            
            categoryTextField.placeholder = "add a category"
            textField = categoryTextField
        }

        let alertAction = UIAlertAction(title: "add", style: .default) { (alertAction) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            
            self.categoryArray.append(newCategory)
            
            self.saveData()
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = self.categoryArray[indexPath.row]
        }
    }
    
    func saveData() {
        
        do {
            try context.save()
        } catch {
            print ("error when saving data \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("error when loading data \(error)")
        }
        tableView.reloadData()
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            context.delete(categoryArray[indexPath.row])
            categoryArray.remove(at: indexPath.row)
            
            saveData()
        }
//            else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
    }
}
