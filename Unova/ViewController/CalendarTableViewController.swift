//
//  CalendarTableViewController.swift
//  Unova
//
//  Created by iosdev on 04/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class CalendarTableViewController: UITableViewController {
    
    //MARK: Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var lectures = [Lecture]()

    //MARK: View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Calendar"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get course list
        guard let coursesOfStudent = appDelegate.user?.course as? Set<Course> else {
            fatalError("Cannot load courses of student")
        }
        
        // Get lecture list
        for course in coursesOfStudent {
            guard let lecture = course.lecture as? Set<Lecture> else {
                fatalError("Cannot load lecture")
            }
            lectures += lecture
            
            //Sort the lecture in order of Date
            self.lectures.sort(by: {$0.date?.compare($1.date as! Date) == .orderedAscending})
            
            //then update table View
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lectures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CalendarTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CalendarTableViewCell else {
            fatalError("Cannot downcast to CalendarTableViewCell")
        }
        
        //fetch appropriate lecture in the list
        let lecture = lectures[indexPath.row]
        
        //Format date into DD-MMM-YYYY
        cell.dateLabelView.text = Util.convertDateString(date: lecture.date as! Date, toFormat: "dd-MMM-yyyy")
        
        cell.timeLabelView.text = Util.transformTime(from: lecture.startTime) + " - " + Util.transformTime(from: lecture.endTime)
        cell.roomLabelView.text = lecture.room
        
        cell.nameLabelView.text = lecture.course?.name
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
