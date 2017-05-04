//
//  Util.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit
import Firebase
import CoreData


class Util{
    
    //Transform date from String
    static func convertFromStringToDate(from dateString: String, to format: String) -> NSDate? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        guard let date = dateFormatter.date(from: dateString) else {
            print("Invalid date")
            return nil
        }
        
        return date as NSDate
    }
    
    //Transform time from Double
    static func transformTime(from time: Double) -> String {
        
        //get minute from the decimal of time
        let minute = Int(floor((time - Double(Int(floor(time)))) * 60))
        var minuteString = String(minute)
        
        if String(minute).characters.count == 1 {
            minuteString = "0" + minuteString
        }
        
        let timeString = String(Int(floor(time))) + "h" + minuteString
        
        return timeString
    }


    //Get Student from Firebase
    static func getStudentData(uid: String, completionHandler: @escaping ([String: Any]) -> Void) {
        
        var studentData = [String: Any]()
        
        //Get reference to database
        FIRDatabase.database().reference().child("student").child(uid).observe(.value, with: { snapshot in
            
            guard let value = snapshot.value as? [String: Any] else {
                fatalError("Downcast to dictionary of User failed")
            }
            
            //load user's information
            studentData["firstName"] = value["first-name"] as! String
            studentData["lastName"] = value["last-name"] as! String
            studentData["email"] = value["email"] as! String
            studentData["id"] = uid
            studentData["courses"] = value["course"] as! [String: String]
            
            //get avatar data
            Util.getAvatar(name: value["avatar"] as! String) { (data, error) in
                if let data = data {
                   studentData["avatar"] = data as NSData
                    
                    completionHandler(studentData)
                } else {
                    print("Error of getting avatar: \(error!)")
                }
            }
        })
    }
    
    //Get Avatar of a Student
    static func getAvatar(name: String, completionHandler: @escaping (NSData?, NSError?) -> Void ) {
        let path = "avatars/" + name
        //Create reference to the avatar in storage
        let storageRef = FIRStorage.storage().reference().child(path)
        //// Download the data, assuming a max size of 1MB
        storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            completionHandler(data as? NSData, error as? NSError)
        }
    }
    
    //Get Single Course Data from Firebase
    static func getCourse(courseId: String, into context: NSManagedObjectContext, completionHandler: @escaping (Course) -> Void) {

        //Get reference to database
        FIRDatabase.database().reference().child("course").child(courseId).observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                fatalError("Downcast to dictionary of course failed")
            }
            
            //Initialize course
            let name = value["name"] as! String
            let lecturer = value["lecturer"] as! String
            let id = courseId
            
            guard let course = Course.init(name: name, id: courseId, lecturer: lecturer, insertInto: context) else {
                fatalError("Cannot init course")
            }
            
            completionHandler(course)
        })
    }
    
    //Get Lectures of a course
    static func getLectures(of courseId: String, into context: NSManagedObjectContext, completionHandler: @escaping ([Lecture]) -> Void) {
        
        var lectureList = [Lecture]()
        
        //Get reference to database
        FIRDatabase.database().reference().child("lecture").child(courseId).observe(.value, with: { snapshot in
            
            //Get a list of Lectures and downcast to a dictionary, which has keys refer to another dictionary
            guard let value = snapshot.value as? [String: [String: Any]] else {
                fatalError("Downcast to dictionary of course failed")
            }
           
            for (lectureId, lectureData) in value {
                let id = lectureId
                
                //transform date
                let dateString = lectureData["date"] as! String
                let date = Util.convertFromStringToDate(from: dateString, to: "yyyy-MM-dd")
                
                let startTime = lectureData["start-time"] as! Double
                let endTime = lectureData["end-time"] as! Double
                let room = lectureData["room"] as! String
                let checkinTime = lectureData["checkin-time"] as? [String: Any]
                
                //init lecture
                guard let lecture = Lecture.init(room: room, endTime: endTime, startTime: startTime, date: date!, id: id, checkinTime: checkinTime as NSDictionary?, insertInto: context) else {
                    fatalError("init lecture failed")
                }
                
                lectureList.append(lecture)
            }
            
            completionHandler(lectureList)
        })
    }
    
    //Save in context
    static func save(in context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}

