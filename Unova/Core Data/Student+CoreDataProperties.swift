//
//  Student+CoreDataProperties.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student");
    }

    @NSManaged public var avatar: NSData?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: String?
    @NSManaged public var lastName: String?
    @NSManaged public var course: NSSet?

}

// MARK: Generated accessors for course
extension Student {

    @objc(addCourseObject:)
    @NSManaged public func addToCourse(_ value: Course)

    @objc(removeCourseObject:)
    @NSManaged public func removeFromCourse(_ value: Course)

    @objc(addCourse:)
    @NSManaged public func addToCourse(_ values: NSSet)

    @objc(removeCourse:)
    @NSManaged public func removeFromCourse(_ values: NSSet)

}
