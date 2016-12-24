//
//  ToDoTaskStore.swift
//  BrandNewToDo
//
//  Created by Rigel Preston on 12/23/16.
//  Copyright © 2016 Rigel Preston. All rights reserved.
//

import UIKit

class ToDoTaskStore {
    
    static let shared = ToDoTaskStore()
    
    fileprivate var tasks: [[Task]] = []
    
    var selectedImage: UIImage?
    
    init() {
        let filePath = archiveFilePath()
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            tasks = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! [[Task]]
        } else {
            for _ in 1...ToDoCatStore.shared.getCategoryCount() {
                tasks.append([])
            }
            tasks[0] = [Task(title: "Example", dueDate: Date(), lastModified: Date(), category: 0, complete: false)]
            tasks[1] = [Task(title: "Example", dueDate: Date(), lastModified: Date(), category: 0, complete: false)]
            tasks[2] = [Task(title: "Example", dueDate: Date(), lastModified: Date(), category: 0, complete: false)]
            save()
        }
    }
    
    // MARK: - Public Functions
    func getTask(_ sectionIndex: Int, _ rowIndex: Int) -> Task {
        return tasks[sectionIndex][rowIndex]
    }
    
    func addNewSection() {
        tasks.append([])
    }
    
    func getAllTasks() -> [[Task]] {
        return tasks
    }
    
    func updateTask(_ task: Task, _ sectionIndex: Int, _ rowIndex: Int) {
        tasks[sectionIndex][rowIndex] = task
        save()
    }
    
    func addTask(_ task: Task) {
        tasks[task.category].insert(task, at: 0)
        save()
    }
    
    func deleteTask(_ sectionIndex: Int, _ rowIndex: Int) {
        tasks[sectionIndex].remove(at: rowIndex)
        save()
    }
    
    func getRowCount(_ sectionIndex: Int) -> Int {
        return tasks[sectionIndex].count
    }
    
    func getIncompleteTasks() -> [[Task]] {
        var returnArray = [[Task]]()
        for _ in 1...ToDoCatStore.shared.getCategoryCount() {
            returnArray.append([])
        }
        for section in 0...tasks.count - 1 {
            for row in 0..<tasks[section].count {
                if tasks[section][row].complete == false {
                    returnArray[section].insert(getTask(section, row), at: 0)
                }
            }
        }
        return returnArray
    }
    
    func removeSection(_ sectionIndex: Int) {
        tasks.remove(at: sectionIndex)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(tasks, toFile: archiveFilePath())
    }
    
    
    // MARK: - Private Functions
    fileprivate func archiveFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first!
        let path = (documentsDirectory as NSString).appendingPathComponent("ToDoTaskStore.plist")
        return path
    }
}

