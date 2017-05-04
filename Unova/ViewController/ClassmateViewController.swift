//
//  ClassmateViewController.swift
//  Unova
//
//  Created by iosdev on 04/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ClassmateViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate{
    
    //MARK: Properties
    
    @IBOutlet weak var coursePickerView: UIPickerView!
    @IBOutlet weak var classmateTableView: UITableView!
    
    var classmates = [Student]()
    var coursesOfStudent = [Course]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let databaseRef = FIRDatabase.database().reference()


    override func viewDidLoad() {
        super.viewDidLoad()

        coursePickerView.dataSource = self
        coursePickerView.delegate = self
        
        classmateTableView.dataSource = self
        classmateTableView.delegate = self
        
        //Transform set of Course to Array
        guard let courseSet = appDelegate.user?.course as? Set<Course> else {
            fatalError("Downcast to Set of courses failed")
        }
        coursesOfStudent = Array(courseSet)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Picker View Data source and Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coursesOfStudent.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coursesOfStudent[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        classmates.removeAll()
        loadClassmates(courseId: coursesOfStudent[row].id!)
    }
    
    //MARK: TableView Data source and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classmates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ClassmateViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ClassmateTableViewCell else {
            fatalError("The dequeued cell is not an instance of ClassmateTableViewCell.")
        }
        
        // Fetches the appropriate student for the data source layout.
        let classmate = classmates[indexPath.row]
        
        let fullName = classmate.firstName! + " " + classmate.lastName!
        
        cell.nameLabelView.text = fullName
        
        //if student doesn't have an avatar, use default one
        if let avatar = classmate.avatar {
            cell.avatarImageView.image = UIImage(data: avatar as Data)
        } else {
            cell.avatarImageView.image = UIImage(named: "DefaultAvatar")
        }
        
        return cell
    }

    //MARK: Private functions
    private func loadClassmates(courseId: String) {
        
        //reference to NSManagedObject Context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //get reference to database
        databaseRef.child("course").child(courseId).child("student").observe(.value, with: { snapshot in
            
            //downcast list of student into dictionary
            guard let value = snapshot.value as? [String: Any] else {
                fatalError("Cannot get list of students in a Course")
            }
            
            for studentId in Array(value.keys) {
                
                //Get Student data from Firebase
                Util.getStudentData(uid: studentId, completionHandler: { result in
                    
                    //Initialize User
                    let firstName = result["firstName"] as! String
                    let lastName = result["lastName"] as! String
                    let avatar = result["avatar"] as! NSData
                    let email = result["email"] as! String
                    let id = result["id"] as! String
                    
                    let student = Student.init(email: email, firstName: firstName, lastName: lastName, id: id, avatar: avatar, insertInto: managedContext)
                    
                    //Add to classmate Array
                    self.classmates.append(student!)
                    
                    self.classmateTableView.reloadData()
                
                })
            }
        })
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
