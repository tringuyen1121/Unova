//
//  Course+CoreDataProperties.swift
//  Unova
//
//  Created by iosdev on 04/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import Foundation
import CoreData


extension Course {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course");
    }

    @NSManaged public var id: String?
    @NSManaged public var lecturer: String?
    @NSManaged public var name: String?
    @NSManaged public var lecture: NSSet?
    @NSManaged public var student: NSSet?

}

// MARK: Generated accessors for lecture
extension Course {

    @objc(addLectureObject:)
    @NSManaged public func addToLecture(_ value: Lecture)

    @objc(removeLectureObject:)
    @NSManaged public func removeFromLecture(_ value: Lecture)

    @objc(addLecture:)
    @NSManaged public func addToLecture(_ values: NSSet)

    @objc(removeLecture:)
    @NSManaged public func removeFromLecture(_ values: NSSet)

}

// MARK: Generated accessors for student
extension Course {

    @objc(addStudentObject:)
    @NSManaged public func addToStudent(_ value: Student)

    @objc(removeStudentObject:)
    @NSManaged public func removeFromStudent(_ value: Student)

    @objc(addStudent:)
    @NSManaged public func addToStudent(_ values: NSSet)

    @objc(removeStudent:)
    @NSManaged public func removeFromStudent(_ values: NSSet)

}
