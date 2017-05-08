//
//  CheckInViewController.swift
//  Unova
//
//  Created by iosdev on 05/05/17.
//  Copyright © 2017 Unova. All rights reserved.
//

import UIKit

class CheckInViewController: UIViewController {

    //MARK: Properites
    @IBOutlet weak var classNameLabelView: UILabel!
    @IBOutlet weak var classIDLabelView: UILabel!
    @IBOutlet weak var lecturerLabelView: UILabel!
    @IBOutlet weak var durationLabelView: UILabel!
    @IBOutlet weak var checkInTimeLabelView: UILabel!
    
    var className: String?
    var classID: String?
    var lecturer: String?
    var duration: String?
    var checkInTime: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get label content
        classNameLabelView.text = className
        classIDLabelView.text = classID
        lecturerLabelView.text = lecturer
        durationLabelView.text = duration
        checkInTimeLabelView.text = checkInTime
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
