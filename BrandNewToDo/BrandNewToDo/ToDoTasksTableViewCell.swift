//
//  ToDoTasksTableViewCell.swift
//  BrandNewToDo
//
//  Created by Rigel Preston on 12/23/16.
//  Copyright © 2016 Rigel Preston. All rights reserved.
//

import UIKit

class ToDoTaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskDueDateLabel: UILabel!
    @IBOutlet weak var taskLastModifiedLabel: UILabel!
    @IBOutlet weak var taskIsDoneSwitch: UISegmentedControl!
    
    
    weak var task: Task!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(_ task: Task) {
        self.task = task
        taskTitleLabel.text = task.title
        taskDueDateLabel.text = task.dueDateString
        
        // Background color for past due and still due
        if task.dueDate.compare(Date()) == .orderedAscending {
            taskDueDateLabel.textColor = #colorLiteral(red: 1, green: 0.1891451776, blue: 0.2564486861, alpha: 1)
        } else {
            taskDueDateLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        
        // Done or not done
        taskLastModifiedLabel.text = task.lastModifiedString
        if task.complete == true {
            taskIsDoneSwitch.selectedSegmentIndex = 0
        } else {
            taskIsDoneSwitch.selectedSegmentIndex = 1
        }
    }
}


