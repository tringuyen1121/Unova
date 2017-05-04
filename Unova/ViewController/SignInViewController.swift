//
//  SignInViewController.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreData

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var signInButtonView: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInIndicatorView: UIActivityIndicatorView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //Reference to database of Firebase
    let databaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up Views
        signInButtonView.layer.cornerRadius = 20
        signInButtonView.clipsToBounds = true
        
        emailTextField.delegate = self
        passwordTextField.delegate = self

    }
    
    //MARK: Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //Disable sign in Button when editing
        signInButtonView.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //Enable sign in Button after editing
        signInButtonView.isEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func signInTapped(_ sender: Any) {
        
        //Animate activity indicator
        self.signInIndicatorView.center = self.view.center
        self.signInIndicatorView.startAnimating()
        
        let username = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if (!username.isEmpty && !password.isEmpty) {
            authenticateWith(username, password: password)
        } else {
            createAlertWithTitle("Alert", message: "Username or Password must not be empty")
        }
    }
    
    //MARK: Private function
    private func authenticateWith(_ email: String, password: String) {
        
        //reference to NSManagedObject Context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password) {(user, error) in
            if error == nil {
                
                //Get Student data from Firebase
                Util.getStudentData(uid: user!.uid, completionHandler: { result in
                    
                    //Initialize User
                    let firstName = result["firstName"] as! String
                    let lastName = result["lastName"] as! String
                    let avatar = result["avatar"] as! NSData
                    let email = result["email"] as! String
                    let id = result["id"] as! String
                    
                    //Load courses of user
                    let course = result["courses"] as! [String: String]
                    
                    for courseId in Array(course.keys) {
                        Util.getCourse(courseId: courseId, completionHandler: { courseData in
                            
                            //Initialize User
                            let name = courseData["name"] as! String
                            let lecturer = courseData["lecturer"] as! String
                            let id = courseId
                            
                            guard let course = Course.init(name: name, id: courseId, lecturer: lecturer, insertInto: managedContext) else {
                                fatalError("Cannot init course")
                            }
                            
                            //Save courses
                            do {
                                //Adding course to student
                                self.appDelegate.user?.addToCourse(course)
                                
                                try managedContext.save()
                            } catch let error as NSError {
                                print("Error of saving course: \(error)")
                            }
                        })
                    }
                    
                    self.appDelegate.user = Student.init(email: email, firstName: firstName, lastName: lastName, id: id, avatar: avatar, insertInto: managedContext)
                    
                    self.saveUser(in: managedContext)
                    
                    print("Saving done")
                    
                    //Navigate to next scene
                    self.signInIndicatorView.startAnimating()
                    self.navigateToHomePage()
                })
            } else {
                self.signInIndicatorView.stopAnimating()
                self.createAlertWithTitle("Error", message: (error?.localizedDescription)!)
            }
        }
    }
    
    private func createAlertWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func saveUser(in context: NSManagedObjectContext) {
        do {
            print("Saving User")
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func navigateToHomePage() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let homePageViewController = storyBoard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController else {
            fatalError("Cannot downcast to HomePageViewController")
        }
        
        let navController: UINavigationController = UINavigationController.init(rootViewController: homePageViewController)
        self.navigationController?.present(navController, animated: true, completion: nil)
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
