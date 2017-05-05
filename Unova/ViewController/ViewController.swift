//
//  ViewController.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var signInButtonView: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var studentResult = [Student]()
    var courseResult = [Course]()
    var lectureResult = [Lecture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //set up the buttons
        signInButtonView.layer.cornerRadius = 20
        signInButtonView.clipsToBounds = true
        
        fetchData()
        
        //Automatic login if there are user data saved
        if let user = studentResult.first {
            
            appDelegate.user = user
            appDelegate.userId = user.id
            
            //Navigate to HomePage
            self.navigateToHomePage()
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Show the navigation bar on other viewControllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func unWindToLaunchingPage(segue: UIStoryboardSegue){
        
    }

    //MARK: Private functions
    private func fetchData() {
        
        //Reference to context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Create fetch request
        let studentRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        let courseRequest = NSFetchRequest<NSManagedObject>(entityName: "Course")
        let lectureRequest = NSFetchRequest<NSManagedObject>(entityName: "Lecture")
        
        do {
            //Assign fetch results to appropriate variables
            guard let studentFetchResult = try managedContext.fetch(studentRequest) as? [Student] else {
                fatalError("Downcast from fetch result failed")
            }
            guard let courseFetchResult = try managedContext.fetch(courseRequest) as? [Course] else {
                fatalError("Downcast from fetch result failed")
            }
            guard let lectureFetchResult = try managedContext.fetch(lectureRequest) as? [Lecture] else {
                fatalError("Downcast from fetch result failed")
            }
            
            studentResult = studentFetchResult
            courseResult = courseFetchResult
            lectureResult = lectureFetchResult
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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


}

