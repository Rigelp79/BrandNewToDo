//
//  ToDoTableViewController.swift
//  BrandNewToDo
//
//  Created by Rigel Preston on 12/23/16.
//  Copyright © 2016 Rigel Preston. All rights reserved.
//

import UIKit

class ToDoTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var showDone: UISwitch!
    
    //MARK: - Class Level Variables
    
    let searchController = UISearchController(searchResultsController: nil)
    var categoryHeaders = ToDoCatStore.shared.getCategories()
    var readyToEdit = true
    var searchFilterArray = [[Task]]()
    var incompleteTasks = ToDoTaskStore.shared.getIncompleteTasks()
    let defaults = UserDefaults.standard
    
    //MARK: - Controller Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.showsVerticalScrollIndicator = true
        tableView.refreshControl = nil
        
        let doneSwitchState = defaults.data(forKey: "showDoneSwitchState")
        if let doneSwitchState = doneSwitchState {
            showDone.isOn = (NSKeyedUnarchiver.unarchiveObject(with: doneSwitchState) as? Bool)!
        } else {
            showDone.isOn = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
        categoryHeaders = ToDoCatStore.shared.getCategories()
        incompleteTasks = ToDoTaskStore.shared.getIncompleteTasks()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let doneSwitchState = NSKeyedArchiver.archivedData(withRootObject: showDone.isOn)
        defaults.set(doneSwitchState, forKey: "showDoneSwitchState")
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditTaskSegue" {
            let taskDetailVC = segue.destination as! ToDoTaskDetailViewController
            let tableCell = sender as! ToDoTaskTableViewCell
            taskDetailVC.task = tableCell.task
        }
    }
    
    //MARK: - TableView Data Source Functions
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Verdana", size: 24)!
        header.textLabel?.textAlignment = .center
        header.textLabel?.textColor = #colorLiteral(red: 0.26, green: 0.47, blue: 0.96, alpha: 1)
        header.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let bottomBorder = UIView(frame: CGRect(x: 0, y: 28, width: self.view.bounds.width, height: 1))
        bottomBorder.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        header.contentView.addSubview(bottomBorder)
        let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1))
        topBorder.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        header.contentView.addSubview(topBorder)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return categoryHeaders.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categoryHeaders[section]
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return searchFilterArray[section].count
        } else if showDone.isOn == false {
            return incompleteTasks[section].count
        } else {
            return ToDoTaskStore.shared.getRowCount(section)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ToDoTaskTableViewCell.self)) as! ToDoTaskTableViewCell
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.setupCell(searchFilterArray[indexPath.section][indexPath.row])
        } else if showDone.isOn == false {
            cell.setupCell(incompleteTasks[indexPath.section][indexPath.row])
        } else {
            cell.setupCell(ToDoTaskStore.shared.getTask(indexPath.section, indexPath.row))
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ToDoTaskStore.shared.deleteTask(indexPath.section, indexPath.row)
            incompleteTasks = ToDoTaskStore.shared.getIncompleteTasks()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //MARK: - Search Bar Filter Functions
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        let allTasks = ToDoTaskStore.shared.getAllTasks()
        let incompleteTasks = self.incompleteTasks
        if showDone.isOn {
            filter(allTasks, searchText)
        } else {
            filter(incompleteTasks, searchText)
        }
        tableView.reloadData()
    }
    
    func filter(_ inputArray: [[Task]], _ searchText: String) {
        searchFilterArray = []
        for _ in 0...ToDoCatStore.shared.getCategoryCount() {
            searchFilterArray.append([])
        }
        for i in 0..<inputArray.count {
            let toAdd = inputArray[i].filter { task in
                return task.title.lowercased().contains(searchText.lowercased())
            }
            if toAdd.count > 0 {
                searchFilterArray[i] = toAdd
            }
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func edit(_ sender: AnyObject) {
        if readyToEdit {
            self.setEditing(true, animated: true)
            editButtonItem.title = "Done"
            readyToEdit = false
        } else {
            self.setEditing(false, animated: true)
            editButtonItem.title = "Edit Tasks"
            readyToEdit = true
        }
    }
    
    @IBAction func saveTaskDetail(_ segue: UIStoryboardSegue) {
        let taskDetailVC = segue.source as! ToDoTaskDetailViewController
        self.isEditing = false
        readyToEdit = true
        if let indexPath = tableView.indexPathForSelectedRow {
            if ToDoTaskStore.shared.getTask(indexPath.section, indexPath.row).category != indexPath.section {
                let placeholder = ToDoTaskStore.shared.getTask(indexPath.section, indexPath.row)
                ToDoTaskStore.shared.deleteTask(indexPath.section, indexPath.row)
                ToDoTaskStore.shared.addTask(placeholder)
            }
            tableView.reloadData()
        } else {
            ToDoTaskStore.shared.addTask(taskDetailVC.task)
            tableView.reloadData()
        }
    }
    
    @IBAction func completionSwitchChanged(_ sender: AnyObject) {
        tableView.reloadData()
    }
    
}

//MARK: - UISearchResultsUpdating Extension

extension ToDoTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

