//
//  ToDoCategory.swift
//  BrandNewToDo
//
//  Created by Rigel Preston on 12/23/16.
//  Copyright © 2016 Rigel Preston. All rights reserved.
//

import UIKit

class ToDoCategory: NSObject, NSCoding {
    var name: String = ""
    
    let nameKey = "name"
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: nameKey) as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: nameKey)
    }
    
    override init() {
        super.init()
    }
    
    init(_ name: String) {
        self.name = name
    }
}

