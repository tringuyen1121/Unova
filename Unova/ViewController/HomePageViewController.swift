//
//  HomePageViewController.swift
//  Unova
//
//  Created by iosdev on 03/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import CoreData


class HomePageViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: Properties
    @IBOutlet weak var helloLabelView: UILabel!
    
    var locationManager: CLLocationManager!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let databaseRef = FIRDatabase.database().reference()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstName = appDelegate.user?.firstName ?? "no username"
        helloLabelView.text = "Hello, \(firstName)"
        
        //locationManager setup
        locationManager = CLLocationManager.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        startScanningForBeaconRegion(beaconRegion: getBeaconRegion())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Show the navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func checkInTapped(_ sender: Any) {
        checkUserIn()
    }
    
    //MARK: CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let beacon = beacons.last
        
        if beacons.count > 0 {
            checkUserIn()
        }
    }
    
    func getBeaconRegion() -> CLBeaconRegion {
        let beaconRegion = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: "5270C0C8-5151-4349-B0B8-649042AE89B6")!, identifier: "com.example.Unova")
        
        return beaconRegion
    }
    
    func startScanningForBeaconRegion(beaconRegion: CLBeaconRegion) {
        print(beaconRegion)
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //Mark: Private methods
    private func checkUserIn() {
        //reference to NSManagedObject Context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //get date and time
        let currentTime = getCurrentDateAndTimeAsString()
        let checkinTime = currentTime["time"] as! Double
        let today = currentTime["date"] as! String
        
        
        //ref to today lecture
        let lectureList = getConnectedCourse().lecture as! Set<Lecture>
        
        for lecture in lectureList {
            let date = Util.convertDateString(date: lecture.date as! Date, toFormat: "yyyy-MM-dd")
            
            if date == today {
                
                //check user in during lecure time
                if checkinTime >= lecture.startTime && checkinTime <= lecture.endTime {
                    guard let userUID = appDelegate.user?.id else {
                        fatalError("Cannot get User uid")
                    }
    
                    //write to database
                    print("writing to database")
                    databaseRef.child("lecture").child(getConnectedCourse().id!).child(lecture.id!).child("checkin-time").updateChildValues([userUID: checkinTime])
                    
                    //Update core data by loading the whole data *too lazy*
                    Util.updateData(completion: { done in })
                }

                break
            }
        }
    }
    
    private func getCurrentDateAndTimeAsString() -> [String: Any] {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        
        //get date
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        //get time
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: date)
        print(timeString)
        let time = Util.transformTimeString(from: timeString)

        var currentTime = [String: Any]()
        currentTime["date"] = dateString
        currentTime["time"] = time
        
        return currentTime
    }
    
    private func getConnectedCourse() -> Course {
        
        //id of course that current beacon connects to
        let courseId = "c001"
        var connectedCourse = Course()
        
        let courseList = appDelegate.user?.course as! Set<Course>
        
        for course in courseList {
            if course.id == courseId {
                connectedCourse = course
                break
            }
        }
        
        return connectedCourse
    }
}
