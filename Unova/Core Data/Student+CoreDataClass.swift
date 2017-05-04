//
//  Student+CoreDataClass.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import Foundation
import CoreData

@objc(Student)
public class Student: NSManagedObject {
    
    //MARK: Initialization
    convenience init?(email: String, firstName: String, lastName: String, id: String, avatar: NSData?, insertInto context: NSManagedObjectContext) {
        
        //Initialization should fail if student has invalid id or no email or names
        if(email.isEmpty || firstName.isEmpty || lastName.isEmpty || id.isEmpty) {
            return nil
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "Student", in: context)
        
        self.init(entity: entity!, insertInto: context)
        
        //Assign properties to their respective values
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.avatar = avatar
    }
}
