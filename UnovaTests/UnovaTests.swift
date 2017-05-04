//
//  UnovaTests.swift
//  UnovaTests
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import XCTest
import CoreData
@testable import Unova

class UnovaTests: XCTestCase {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //MARK: Course Class Test
    
    // Confirm that the Course initializer returns a Course object when passed valid parameters.
    func testCourseInitializationSucceeds() {
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let validCourse = Course.init(name: "This is sample Course", id: "c000", lecturer: "Jaakko Leinonen", insertInto: context)
        XCTAssertNotNil(validCourse)
        
    }
    
    // Confirm that the Course initialier returns nil when passed an invalid id or missing other parameter.
    func testCourseInitializationFails() {
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        //Invalid id
        let noIdCourse = Course.init(name: "This is sample Course", id: "", lecturer: "Jaakko Leinonen", insertInto: context)
        XCTAssertNil(noIdCourse)
        
        //Invalid name
        let noNameCourse = Course.init(name: "", id: "c000", lecturer: "Jaakko Leinonen", insertInto: context)
        XCTAssertNil(noNameCourse)
        
        //Invalid lecturer
        let noLecturerCourse = Course.init(name: "This is another course", id: "c000", lecturer: "", insertInto: context)
        XCTAssertNil(noLecturerCourse)
    }
    
    //MARK: Lecture Class Test

    // Confirm that the Lecture initializer returns a Lecture object when passed valid parameters.
    func testLectureInitializationSucceeds() {
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let date = Util.convertFromStringToDate(from: "2017-04-03", to: "yyyy-MM-dd")
        
        let validLecture = Lecture.init(room: "ABY000", endTime: 24.0, startTime: 0.0, date: date!, id: "l001", course: nil, insertInto: context)
        XCTAssertNotNil(validLecture)
        
    }
    
    // Confirm that the Lecture initializer returns nil when passed invalid parameters.
    func testLectureInitializationFails() {
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let date = Util.convertFromStringToDate(from: "2017-04-03", to: "yyyy-MM-dd")

        //Empty Id
        let invalidIdLecture = Lecture.init(room: "ABY000", endTime: 24.0, startTime: 0.0, date: date!, id: "", course: nil, insertInto: context)
        XCTAssertNil(invalidIdLecture)
        
        //Invalid Time
        let invalidEndTimeLecture = Lecture.init(room: "ABY000", endTime: 24.1, startTime: 0.0, date: date!, id: "l001", course: nil, insertInto: context)
        XCTAssertNil(invalidEndTimeLecture)
        
        let invalidStartTimeLecture = Lecture.init(room: "ABY000", endTime: 24.0, startTime: -0.1, date: date!, id: "l001", course: nil, insertInto: context)
        XCTAssertNil(invalidStartTimeLecture)
        
        //Empty room
        let invalidRoomLecture = Lecture.init(room: "", endTime: 24.0, startTime: 0.0, date: date!, id: "l001", course: nil, insertInto: context)
        XCTAssertNil(invalidRoomLecture)
    }

}
