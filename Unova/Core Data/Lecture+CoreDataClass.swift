//
//  Lecture+CoreDataClass.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import Foundation
import CoreData

@objc(Lecture)
public class Lecture: NSManagedObject {
    
    convenience init?(room: String, endTime: Double, startTime: Double, date: NSDate, id: String, checkinTime: NSDictionary?, insertInto context: NSManagedObjectContext) {
        
        //Initialization should fail if trying to initialize invalid course
        if room.isEmpty || id.isEmpty || room.isEmpty || startTime > 24.0 || startTime < 0.0 || endTime > 24.0 || endTime < 0.0 {
            return nil
        }
        
        //Init an entity for lecture
        let entity = NSEntityDescription.entity(forEntityName: "Lecture", in: context)
        
        self.init(entity: entity!, insertInto: context)
        
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.room = room
        self.date = date
        self.checkinTime = checkinTime
    }


}
