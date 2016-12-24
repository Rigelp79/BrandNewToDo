//
//  ToDoEditCatTableViewController.swift
//  BrandNewToDo
//
//  Created by Rigel Preston on 12/23/16.
//  Copyright © 2016 Rigel Preston. All rights reserved.
//

import UIKit

class ToDoEditCatTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var categoryToAdd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoryToAdd.delegate = self
        categoryToAdd.autocapitalizationType = .sentences
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ToDoCatStore.shared.getCategoryCount()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        cell.textLabel?.text = ToDoCatStore.shared.getCategory(indexPath.row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ToDoCatStore.shared.removeCategory(indexPath.row)
            ToDoTaskStore.shared.removeSection(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func addCategory(_ sender: AnyObject) {
        if categoryToAdd.text != "" {
            ToDoCatStore.shared.addCategory(categoryToAdd.text!)
            ToDoTaskStore.shared.addNewSection()
            categoryToAdd.resignFirstResponder()
            tableView.reloadData()
        }
        categoryToAdd.text = ""
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCategory" {
            let taskDetailVC = segue.destination as! ToDoCatDetailViewController
            let tableCell = sender as! UITableViewCell
            taskDetailVC.category.name = (tableCell.textLabel?.text)!
        }
    }
    
    @IBAction func saveCategoryDetail(_ segue: UIStoryboardSegue) {
        let taskDetailVC = segue.source as! ToDoCatDetailViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            ToDoCatStore.shared.updateCategory(indexPath.row, taskDetailVC.category.name)
            tableView.reloadData()
        }
    }
}




