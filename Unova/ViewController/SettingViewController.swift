//
//  SettingViewController.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit
import CoreData

class SettingViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    //MARK: Properties
    @IBOutlet weak var signOutButtonView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up the buttons
        signOutButtonView.layer.cornerRadius = 20
        signOutButtonView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        deleteAllData()
        
        //Clear variables in AppDelegte
        appDelegate.user = nil

        //Navigate back to Launching Page
        
        self.performSegue(withIdentifier: "UnWindToLaunchingPage", sender: self)
    }
    
    //MARK: Private methods
    private func deleteAllData() {
        
        //Reference to context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Create fetch request
        let studentFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        let studentRequest = NSBatchDeleteRequest(fetchRequest: studentFetch)
        
        let courseFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")
        let courseRequest = NSBatchDeleteRequest(fetchRequest: courseFetch)
        
        let lectureFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Lecture")
        let lectureRequest = NSBatchDeleteRequest(fetchRequest: lectureFetch)
        
        do {
            try managedContext.execute(studentRequest)
            try managedContext.execute(courseRequest)
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
