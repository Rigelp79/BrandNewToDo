//
//  ToDoTasks.swift
//  BrandNewToDo
//
//  Created by Rigel Preston on 12/23/16.
//  Copyright © 2016 Rigel Preston. All rights reserved.
//

import UIKit

class Task: NSObject, NSCoding {
    
    // Initialize new task for editing
    var title = ""
    var dueDate = Date()
    var image: UIImage?
    var dueDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        return dateFormatter.string(from: dueDate)
    }
    var lastModified = Date()
    var lastModifiedString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: lastModified)
    }
    var category = 0
    var complete = false
    
    //Keys for encoding and decoding
    let titleKey = "title"
    let dueDateKey = "dueDate"
    let imageKey = "image"
    let lastModifiedKey = "lastModifiedDate"
    let categoryKey = "category"
    let completionKey = "complete"
    
    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: titleKey) as! String
        self.dueDate = aDecoder.decodeObject(forKey: dueDateKey) as! Date
        self.image = aDecoder.decodeObject(forKey: imageKey) as? UIImage
        self.lastModified = aDecoder.decodeObject(forKey: lastModifiedKey) as! Date
        self.category = aDecoder.decodeInteger(forKey: categoryKey)
        self.complete = aDecoder.decodeBool(forKey: completionKey)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: titleKey)
        aCoder.encode(dueDate, forKey: dueDateKey)
        aCoder.encode(image, forKey: imageKey)
        aCoder.encode(lastModified, forKey: lastModifiedKey)
        aCoder.encode(category, forKey: categoryKey)
        aCoder.encode(complete, forKey: completionKey)
    }
    
    override init() {
        super.init()
    }
    
    init(title: String, dueDate: Date, lastModified: Date, category: Int, complete: Bool) {
        self.title = title
        self.dueDate = dueDate
        self.lastModified = lastModified
        self.category = category
        self.complete = complete
    }
}


