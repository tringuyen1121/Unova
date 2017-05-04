//
//  SettingViewController.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class SettingViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    //MARK: Properties
    @IBOutlet weak var signOutButtonView: UIButton!
    @IBOutlet weak var updateDataButtonView: UIButton!
    
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up the buttons
        signOutButtonView.layer.cornerRadius = 20
        signOutButtonView.clipsToBounds = true
        updateDataButtonView.layer.cornerRadius = 20
        updateDataButtonView.clipsToBounds = true
        
        self.title = "Setting"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func signOutTapped(_ sender: Any) {
        
        deleteAllData()
        
        //Clear variables in AppDelegte
        appDelegate.user = nil

        //Navigate back to Launching Page
        
        self.performSegue(withIdentifier: "UnWindToLaunchingPage", sender: self)
    }
    
    @IBAction func updateDataTapped(_ sender: Any) {
        
        //Animate activity indicator view
        self.loadingIndicatorView.center = self.view.center
        self.loadingIndicatorView.startAnimating()
        
        //Reference to context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        deleteCourseData()
        deleteLetureData()
        
        //Get Student data from Firebase
        Util.getStudentData(uid: (appDelegate.user?.id)!, completionHandler: { result in
            
            //Initialize User
            let course = result["courses"] as! [String: String]
            
            //Load courses of user
            for courseId in Array(course.keys) {
                Util.getCourse(courseId: courseId, into: managedContext, completionHandler: { course in
                    
                    //Load lectures
                    Util.getLectures(of: course.id!, into: managedContext, completionHandler: {array in
                        let lectureSet = NSSet(array: array)
                        course.addToLecture(lectureSet)
                        
                        Util.save(in: managedContext)
                        self.loadingIndicatorView.stopAnimating()
                    })
                    
                    //Adding course to student
                    self.appDelegate.user?.addToCourse(course)
                    
                    //Save courses
                    Util.save(in: managedContext)
                })
            }
        
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Error of updating: \(error)")
            }
        })
    }
    
    //MARK: Private methods
    private func deleteAllData() {
        deleteLetureData()
        deleteStudentData()
        deleteCourseData()
    }
    
    private func deleteStudentData() {
        
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
    
    private func deleteCourseData() {
    
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
    
    private func deleteLetureData() {
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
