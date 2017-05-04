//
//  Lecture+CoreDataProperties.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import Foundation
import CoreData

extension Lecture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lecture> {
        return NSFetchRequest<Lecture>(entityName: "Lecture");
    }

    @NSManaged public var checkinTime: NSDictionary?
    @NSManaged public var endTime: Double
    @NSManaged public var id: String?
    @NSManaged public var room: String?
    @NSManaged public var startTime: Double
    @NSManaged public var date: NSDate?
    @NSManaged public var course: Course?

}
