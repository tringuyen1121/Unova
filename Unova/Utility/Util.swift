//
//  Util.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit
import Firebase


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
    static func getCourse(courseId: String, completionHandler: @escaping ([String: Any]) -> Void) {
        
        var courseData = [String: Any]()
        
        //Get reference to database
        FIRDatabase.database().reference().child("course").child(courseId).observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                fatalError("Downcast to dictionary of course failed")
            }
            
            //load course information
            courseData["lecturer"] = value["lecturer"] as! String
            courseData["name"] =  value["name"] as! String
            courseData["id"] = courseId
            
            completionHandler(courseData)
        })
    }
    
    //Get Lectures of a course

}

