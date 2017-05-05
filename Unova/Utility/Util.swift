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
    
    //Transform from date to String in format
    static func convertDateString(date: Date, toFormat desFormat : String!) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = desFormat
        
        return dateFormatter.string(from: date)
    }
    
    //Transform time from Double
    static func transformTime(from time: Double) -> String {
        
        //get minute from the decimal of time
        let minute = Int(floor((time - Double(Int(floor(time)))) * 60))
        var minuteString = String(minute)
        
        if String(minute).characters.count == 1 {
            minuteString = "0" + minuteString
        }
        
        let timeString = String(Int(floor(time))) + ":" + minuteString
        
        return timeString
    }
    
    //Transform time String to Double
    static func transformTimeString(from timeString: String) -> Double {
        
        let numberOfDecimalPlace: Double = 2
        
        //get minute from the decimal of time
        let indexForHour = timeString.index(timeString.startIndex, offsetBy: 2)
        let indexForMinute = timeString.index(timeString.startIndex, offsetBy: 3)
        let hour = Double(timeString.substring(to: indexForHour))
        let minute = Double(timeString.substring(from: indexForMinute))
        
        print(minute!/60.0)
        let time = hour! + (minute!/60.0)
        
        //round to 2 decimal place
        let roundedTime = Double(round(numberOfDecimalPlace * 10 * time) / (numberOfDecimalPlace * 10))

        return roundedTime
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
    
    //Update date
    static func updateData(completion: @escaping (Bool) -> Void ) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //Reference to context
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        
        deleteLetureData()
        deleteCourseData()
        deleteStudentData()
        
        //Get Student data from Firebase
        getStudentData(uid: appDelegate.userId!, completionHandler: { result in
            
            //Initialize User
            //Initialize User
            let firstName = result["firstName"] as! String
            let lastName = result["lastName"] as! String
            let avatar = result["avatar"] as! NSData
            let email = result["email"] as! String
            let id = result["id"] as! String
            let course = result["courses"] as! [String: String]
            
            //Load courses of user
            for courseId in Array(course.keys) {
                getCourse(courseId: courseId, into: managedContext, completionHandler: { course in
                    
                    //Load lectures
                    getLectures(of: course.id!, into: managedContext, completionHandler: {array in
                        let lectureSet = NSSet(array: array)
                        course.addToLecture(lectureSet)
                        
                        save(in: managedContext)
                        
                        completion(true)
                    })
                    
                    //Adding course to student
                    appDelegate.user?.addToCourse(course)
                    
                    //Save courses
                    save(in: managedContext)
                })
            }
            
            appDelegate.user = Student.init(email: email, firstName: firstName, lastName: lastName, id: id, avatar: avatar, insertInto: managedContext)
            
            save(in: managedContext)
        })
    }

    //DeleteData
    static func deleteStudentData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //Reference to context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Create fetch request
        let studentFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        let studentRequest = NSBatchDeleteRequest(fetchRequest: studentFetch)
        
        do {
            try managedContext.execute(studentRequest)
            
            try managedContext.save()
        } catch let error as NSError {
            print("Error of deleting: \(error)")
        }
    }
    
    static func deleteCourseData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //Reference to context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let courseFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")
        let courseRequest = NSBatchDeleteRequest(fetchRequest: courseFetch)
        
        do {
            try managedContext.execute(courseRequest)
            
            try managedContext.save()
        } catch let error as NSError {
            print("Error of deleting: \(error)")
        }
        
    }
    
    static func deleteLetureData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //Reference to context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let lectureFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Lecture")
        let lectureRequest = NSBatchDeleteRequest(fetchRequest: lectureFetch)
        
        do {
            try managedContext.execute(lectureRequest)
            
            try managedContext.save()
        } catch let error as NSError {
            print("Error of deleting: \(error)")
        }
        
    }

}

