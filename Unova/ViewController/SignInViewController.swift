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
        
        // Proceed to sign in
        if (!username.isEmpty && !password.isEmpty) {
            authenticateWith(username, password: password)
        } else {
            createAlertWithTitle("Alert", message: "Username or Password must not be empty")
        }
    }
    
    //MARK: Private function
    // Sign user in
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
                    let course = result["courses"] as! [String: String]
                    
                    //Load courses of user
                    for courseId in Array(course.keys) {
                        Util.getCourse(courseId: courseId, into: managedContext, completionHandler: { course in
                            
                            //Load lectures
                            Util.getLectures(of: course.id!, into: managedContext, completionHandler: {array in
                                let lectureSet = NSSet(array: array)
                                course.addToLecture(lectureSet)
                                
                                Util.save(in: managedContext)
                            })
                            
                            //Adding course to student
                            self.appDelegate.user?.addToCourse(course)
                            
                            //Save courses
                            Util.save(in: managedContext)
                        })
                    }
                    
                    self.appDelegate.user = Student.init(email: email, firstName: firstName, lastName: lastName, id: id, avatar: avatar, insertInto: managedContext)
                    self.appDelegate.userId = user!.uid
                    
                    Util.save(in: managedContext)
                    
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
    
    /*
    func authenticateWith(_ username: String, password: String) {
        let request = NSMutableURLRequest()
        request.httpMethod = "POST"
        request.url = NSURL(string: urlString) as URL?
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = "username=\(username)&password=\(password)"
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
            guard let data = data, error == nil else {
                print("error=\(error)")
                
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("StatusCode should be 200, but is \(httpStatus.statusCode)")
                self.createAlertWithTitle("Error", message: "Username or password is wrong")
                print("respone =\(response)")
            }
            
            
            do {
                
                //parse JSON from response
                let responseJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [ String : Any ]
                let user = responseJSON["user"] as? [ String: Any ]
                
                self.saveUser(email: self.emailTextField.text!, password: self.passwordTextField.text!)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.token = responseJSON["token"] as? String ?? ""
                appDelegate.username = user?["username"] as? String ?? ""
                appDelegate.signedIn = true
                
                //Navigate to next scene
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                guard let homePageViewController = storyBoard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController else {
                    fatalError("Cannot downcast to HomePageViewController")
                }
                let navController: UINavigationController = UINavigationController.init(rootViewController: homePageViewController)
                self.navigationController?.present(navController, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error)
            }
            
        }).resume()
    }
    */
    
    private func createAlertWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
