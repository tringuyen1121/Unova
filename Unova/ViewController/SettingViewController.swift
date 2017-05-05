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
        
        Util.updateData(completion: { done in
            self.loadingIndicatorView.stopAnimating()
        })
        
    }
    
    //MARK: Private methods
    private func deleteAllData() {
        Util.deleteLetureData()
        Util.deleteStudentData()
        Util.deleteCourseData()
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
