//
//  Course+CoreDataClass.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import Foundation
import CoreData

@objc(Course)
public class Course: NSManagedObject {
    
    convenience init?(name: String, id: String, lecturer: String, insertInto context: NSManagedObjectContext) {
        
        //Initialization should fail if trying to initialize invalid course
        if name.isEmpty || id.isEmpty || lecturer.isEmpty {
            return nil
        }
        
        //Init an entity for course
        let entity = NSEntityDescription.entity(forEntityName: "Course", in: context)
        
        self.init(entity: entity!, insertInto: context)
        
        self.name = name
        self.id = id
        self.lecturer = lecturer
    }


}
